#!/usr/bin/env python3
"""Check native production graph/dispatch evidence without allocator code."""
import json
import sys
from pathlib import Path
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from witnesses import check_coloring, require

lines = (HERE / 'dispatch-probe.log').read_text().splitlines()
observed = [json.loads(line) for line in lines if line.startswith('{')]
expected = [
    {'method:linear-scan-allocator': 1, 'policy:linear-scan-engine': 1, 'policy:linear-scan-choice': 2},
    {'method:greedy-allocator': 1, 'policy:greedy': 1},
    {'method:backtracking-allocator': 1, 'policy:backtracking': 1},
    {'method:chordal-allocator': 1, 'policy:chordal-pressure': 1, 'policy:chordal-colors': 1},
]
require(observed == expected, 'wrong policy bodies or alternate-policy invocation')
rows = [json.loads(line) for line in (HERE / 'chordal-witness.log').read_text().splitlines()
        if line.startswith('{')]
require({(r['width'], r['seed']) for r in rows} == {(w, s) for w in (4, 6, 12) for s in range(3)},
        'incomplete native witness matrix')
require(len(rows) == 9, 'duplicate native witnesses')
for row in rows:
    require(row['algorithm'] == 'decoupled-ssa-chordal', 'wrong algorithm')
    require(row['fallback-count'] == row['repair-assignments'] == 0, 'fallback or interval repair')
    require(row['pressure-stores'] > 0 and row['reload-definitions'] > 0, 'pressure fixture did not spill')
    g = {str(k): set(map(str, v)) for k, v in row['interference-graph'].items()}
    order = list(map(str, row['perfect-elimination-order']))
    remaining = set(g)
    bound = 0
    for vertex in order:
        remaining.remove(vertex)
        bound = max(bound, 1 + len(g[vertex] & remaining))
    # check_coloring independently checks symmetry, every edge, permutation,
    # all later-neighbor cliques, exact bound, and uniform-bank optimality.
    check_coloring(dict(graph=row['interference-graph'], colors=row['colors'],
        allowed={v: list(range(4)) for v in g}, elimination_order=order,
        clique_size=bound, uniform_register_file=True))
print('PASS: four concrete backend bodies; nine native pressure CFGs/45 formula answers; all PEOs and 4-register optimal colorings')
