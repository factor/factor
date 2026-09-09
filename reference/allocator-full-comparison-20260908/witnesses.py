#!/usr/bin/env python3
"""Independent, small-fixture checks for allocator mechanism witnesses.

These checks validate exported mathematical facts, not the producer's counters.
They do not establish that a production compiler emitted a truthful witness:
source/dispatch inspection and native execution remain separate requirements.
Factor program-point ranges are INCLUSIVE, unlike regalloc2's half-open ranges.
"""
import argparse
import itertools
import json
from pathlib import Path


def require(condition, message):
    if not condition:
        raise ValueError(message)


def points(ranges):
    """Deliberately enumerate bounded fixtures instead of copying production indexes."""
    result = set()
    for lo, hi in ranges:
        require(isinstance(lo, int) and isinstance(hi, int), "noninteger range")
        require(0 <= lo <= hi <= 100000, "range outside bounded fixture")
        current = set(range(lo, hi + 1))
        require(not result.intersection(current), "overlapping ranges in one value")
        result.update(current)
    return result


def graph(value):
    result = {str(k): set(map(str, neighbors)) for k, neighbors in value.items()}
    for vertex, neighbors in result.items():
        require(vertex not in neighbors, "self interference")
        require(neighbors <= result.keys(), "unknown interference vertex")
        require(all(vertex in result[n] for n in neighbors), "asymmetric interference")
    return result


def coloring(g, colors, allowed=None):
    require(set(colors) == set(g), "missing or extra colored vertex")
    for vertex, neighbors in g.items():
        require(all(colors[vertex] != colors[n] for n in neighbors), "interference color conflict")
        if allowed is not None:
            require(colors[vertex] in allowed[vertex], "illegal physical register")


def check_coloring(w):
    g = graph(w["graph"])
    coloring(g, w["colors"], w.get("allowed"))
    if "elimination_order" not in w:
        return
    order = list(map(str, w["elimination_order"]))
    require(len(order) == len(g) and set(order) == set(g), "order is not a permutation")
    remaining = set(g)
    clique_size = 0
    for vertex in order:
        remaining.remove(vertex)
        later = g[vertex] & remaining
        for neighbor in later:
            require(later - {neighbor} <= g[neighbor], "order is not perfect elimination")
        clique_size = max(clique_size, len(later) + 1)
    require(w["clique_size"] == clique_size, "wrong clique certificate")
    if w.get("uniform_register_file"):
        require(len(set(w["colors"].values())) == clique_size, "uniform coloring is not optimal")


def check_split(w):
    original = points(w["parent_ranges"])
    combined = set()
    child_points = {}
    for child in w["children"]:
        require(child["id"] not in child_points, "duplicate split child")
        occupied = points(child["ranges"])
        require(occupied and not occupied.intersection(combined), "empty or overlapping split child")
        combined.update(occupied)
        child_points[child["id"]] = occupied
        require(set(child["uses"]) <= occupied, "child use outside its ranges")
    require(combined == original, "split lost or invented live points")
    original_uses = sorted(w["parent_uses"])
    child_uses = sorted(u for c in w["children"] for u in c["uses"])
    require(original_uses == child_uses, "split lost or duplicated uses")
    require(len(child_points) > 1, "split did not make progress")
    require(all(len(p) < len(original) for p in child_points.values()), "unchanged split child")


def check_bundle(w):
    combined = set()
    members = set()
    for member in w["members"]:
        require(member["ssa_value"] not in members, "duplicate SSA bundle member")
        members.add(member["ssa_value"])
        occupied = points(member["ranges"])
        require(not combined.intersection(occupied), "overlapping distinct SSA bundle values")
        combined.update(occupied)
        require(member["representation"] == w["representation"], "incompatible bundle representation")
    require(len(members) > 1, "bundle contains no distinct SSA values")
    require(combined == points(w["bundle_ranges"]), "bundle range union changed")


def check_eviction(w):
    requested = points(w["request_ranges"])
    before = {entry["id"]: entry for entry in w["before"]}
    require(len(before) == len(w["before"]), "duplicate allocation owner")
    actual_conflicts = {identity for identity, entry in before.items()
                        if requested.intersection(points(entry["ranges"]))}
    evicted = set(w["evicted"])
    require(actual_conflicts and evicted == actual_conflicts, "eviction did not cover exact conflicts")
    require(evicted == set(w["requeued"]), "evicted allocation was lost instead of requeued")
    for identity in evicted:
        require(not before[identity].get("fixed", False), "evicted a fixed allocation")
        if w.get("strict_weight"):
            require(w["request_weight"] > before[identity]["weight"], "nonprogressing weight eviction")
    after = {entry["id"]: entry for entry in w["after"]}
    require(set(after) == (set(before) - evicted) | {w["request_id"]}, "wrong owners after eviction")
    require(points(after[w["request_id"]]["ranges"]) == requested, "request assigned wrong ranges")
    for identity in set(before) - evicted:
        require(before[identity] == after[identity], "unrelated allocation changed during eviction")


def check_spillsets(w):
    homes = {}
    for spillset in w["spillsets"]:
        occupied = points(spillset["ranges"])
        key = spillset["slot"]
        for previous in homes.get(key, []):
            require(previous["representation"] == spillset["representation"], "incompatible shared slot")
            require(not occupied.intersection(points(previous["ranges"])), "overlapping spillsets share slot")
        homes.setdefault(key, []).append(spillset)
        require(all(child["slot"] == key for child in spillset["children"]), "split descendants disagree on home")
    require(any(len(sets) > 1 for sets in homes.values()), "no actual spill-slot reuse")


def check_recolor(w):
    g = graph(w["graph"])
    pending = w.get("new_request")
    before_graph = {v: neighbors - {pending} for v, neighbors in g.items() if v != pending}
    coloring(before_graph, w["before"], w.get("allowed"))
    coloring(g, w["after"], w.get("allowed"))
    require(any(w["before"][v] != w["after"][v] for v in before_graph), "no existing assignment recolored")
    for vertex in w.get("fixed", []):
        require(w["before"][vertex] == w["after"][vertex], "recolored fixed vertex")
    if pending is not None:
        require(pending in g and pending not in w["before"], "request was already assigned")
        return
    def cost(colors):
        return sum(weight for left, right, weight in w["affinities"] if colors[left] != colors[right])
    require(cost(w["after"]) < cost(w["before"]), "recoloring did not improve weighted affinity cost")


def check_rollback(w):
    for field in ("unions", "index", "serial", "assignments"):
        require(field in w["before"] and field in w["after"], "incomplete rollback snapshot")
    require(w["before"] == w["after"], "failed search did not restore exact allocation state")


def check_placement(w):
    """Exhaustively check small binary CFG residency problems, not a flow solver."""
    nodes = w["costs"]
    require(0 < len(nodes) <= 12, "placement witness exceeds exhaustive bound")
    require(set(w["resident"]) == set(nodes), "placement omits CFG nodes")
    for costs in nodes.values():
        require(len(costs) == 2 and all(isinstance(c, int) and c >= 0 for c in costs),
                "invalid memory/register unary costs")
    for left, right, cost in w["edges"]:
        require(left in nodes and right in nodes and isinstance(cost, int) and cost >= 0,
                "invalid CFG transition cost")
    def legal(resident):
        return all(value in (0, 1) for value in resident.values()) and all(
            resident[node] == value for node, value in w.get("hard", {}).items())
    def cost(resident):
        return sum(nodes[node][value] for node, value in resident.items()) + sum(
            weight for left, right, weight in w["edges"] if resident[left] != resident[right])
    require(legal(w["resident"]), "placement violates hard residency constraints")
    candidates = (dict(zip(nodes, values)) for values in itertools.product((0, 1), repeat=len(nodes)))
    optimum = min(cost(candidate) for candidate in candidates if legal(candidate))
    require(cost(w["resident"]) == optimum, "CFG placement is not minimum cost")
    require(w["cost"] == optimum, "reported placement cost differs")


CHECKS = {"coloring": check_coloring, "split": check_split, "bundle": check_bundle,
          "eviction": check_eviction, "spillsets": check_spillsets, "recolor": check_recolor,
          "rollback": check_rollback, "placement": check_placement}


def validate(document):
    counts = {}
    for witness in document["witnesses"]:
        kind = witness["kind"]
        require(kind in CHECKS, "unknown witness kind")
        CHECKS[kind](witness)
        counts[kind] = counts.get(kind, 0) + 1
    require(counts, "empty witness document")
    return counts


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("witness_file", type=Path)
    args = parser.parse_args()
    counts = validate(json.loads(args.witness_file.read_text()))
    print(json.dumps({"witness_invariants_passed": counts,
                      "native_execution_or_source_completeness_certified": False}, sort_keys=True))
