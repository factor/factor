"""Negative controls for independent mechanism checks; these are synthetic data."""
import copy
import unittest

import witnesses as audit


class WitnessChecks(unittest.TestCase):
    def rejected(self, checker, sample, mutate):
        checker(sample)
        corrupted = copy.deepcopy(sample)
        mutate(corrupted)
        with self.assertRaises(ValueError):
            checker(corrupted)

    def test_inclusive_touch_is_interference(self):
        self.assertEqual(audit.points([[0, 2]]) & audit.points([[2, 4]]), {2})

    def test_coloring_and_perfect_order(self):
        sample = dict(graph={"a": ["b"], "b": ["a", "c"], "c": ["b"]},
                      colors={"a": 0, "b": 1, "c": 0},
                      elimination_order=["a", "c", "b"], clique_size=2,
                      uniform_register_file=True)
        self.rejected(audit.check_coloring, sample, lambda x: x["colors"].update(b=0))
        self.rejected(audit.check_coloring, sample,
                      lambda x: x.update(elimination_order=["b", "a", "c"]))

    def test_split_preserves_holes_and_uses(self):
        sample = dict(parent_ranges=[[0, 2], [6, 9]], parent_uses=[0, 2, 8, 9],
                      children=[dict(id="left", ranges=[[0, 2]], uses=[0, 2]),
                                dict(id="right", ranges=[[6, 9]], uses=[8, 9])])
        self.rejected(audit.check_split, sample,
                      lambda x: x["children"][1].update(ranges=[[3, 9]]))
        self.rejected(audit.check_split, sample,
                      lambda x: x["children"][1].update(uses=[8]))

    def test_bundle_preserves_distinct_ssa_values(self):
        sample = dict(representation="int", bundle_ranges=[[0, 6]], members=[
            dict(ssa_value=1, representation="int", ranges=[[0, 2]]),
            dict(ssa_value=2, representation="int", ranges=[[3, 6]])])
        self.rejected(audit.check_bundle, sample,
                      lambda x: x["members"][1].update(ranges=[[2, 6]]))

    def test_eviction_requeues_every_conflict(self):
        sample = dict(request_id="new", request_ranges=[[3, 4]], request_weight=3,
                      strict_weight=True,
                      before=[dict(id="old", ranges=[[2, 5]], weight=2)],
                      evicted=["old"], requeued=["old"],
                      after=[dict(id="new", ranges=[[3, 4]], weight=3)])
        self.rejected(audit.check_eviction, sample, lambda x: x.update(requeued=[]))
        self.rejected(audit.check_eviction, sample, lambda x: x.update(request_weight=2))

    def test_shared_homes_do_not_overlap(self):
        sample = dict(spillsets=[
            dict(slot=0, representation="int", ranges=[[0, 2]], children=[dict(slot=0)]),
            dict(slot=0, representation="int", ranges=[[3, 5]], children=[dict(slot=0)])])
        self.rejected(audit.check_spillsets, sample,
                      lambda x: x["spillsets"][1].update(ranges=[[2, 5]]))

    def test_coalescing_recolors_without_breaking_graph(self):
        sample = dict(graph={"a": ["b"], "b": ["a"], "c": []},
                      before={"a": 0, "b": 1, "c": 1},
                      after={"a": 0, "b": 1, "c": 0}, affinities=[["a", "c", 4]])
        self.rejected(audit.check_recolor, sample, lambda x: x["after"].update(b=0))

    def test_augmenting_recolor_assigns_pending_request(self):
        sample = dict(graph={"a": ["b", "c"], "b": ["a", "c"], "c": ["a", "b"]},
                      before={"a": 0, "b": 1}, after={"a": 1, "b": 2, "c": 0},
                      allowed={"a": [0, 1], "b": [1, 2], "c": [0]}, new_request="c")
        self.rejected(audit.check_recolor, sample, lambda x: x["after"].update(c=2))

    def test_rollback_restores_index_serial(self):
        state = dict(unions={"r0": [1]}, index=[[0, 2, 1]], serial=3, assignments={"1": "r0"})
        sample = dict(before=state, after=copy.deepcopy(state))
        self.rejected(audit.check_rollback, sample, lambda x: x["after"].update(serial=4))

    def test_cfg_placement_accounts_for_transparent_block(self):
        sample = dict(costs={"a": [4, 0], "b": [0, 0], "c": [4, 0]},
                      edges=[["a", "b", 3], ["b", "c", 3]],
                      resident={"a": 1, "b": 1, "c": 1}, cost=0)
        self.rejected(audit.check_placement, sample, lambda x: x["resident"].update(b=0))
        sample.update(hard={"b": 0}, resident={"a": 1, "b": 0, "c": 1}, cost=6)
        self.rejected(audit.check_placement, sample, lambda x: x["resident"].update(b=1))


if __name__ == "__main__":
    unittest.main()
