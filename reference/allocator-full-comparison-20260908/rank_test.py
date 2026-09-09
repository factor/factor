"""Synthetic aggregation and incomplete-experiment negative controls."""
import copy
import unittest

import rank


class RankingChecks(unittest.TestCase):
    def fixture(self):
        result = dict(source_commits=dict(candidate="synthetic-test-only"), failed_runs=[],
                      options=dict(candidate={}), scope_words=dict(candidate=26), allocators={})
        for index, allocator in enumerate(rank.ALLOCATORS):
            scale = index + 1
            values = {metric: dict(candidate=scale, baseline=1, samples=[6, 6]) for metric in rank.METRICS}
            result["allocators"][allocator] = dict(
                compile=copy.deepcopy(values), runtime_by_round={"1": {}, "2": {}},
                workloads={str(i): copy.deepcopy(values) for i in range(26)})
        return result

    def test_known_ratios(self):
        result = rank.rank(self.fixture())
        for index, allocator in enumerate(rank.ALLOCATORS):
            self.assertAlmostEqual(result["allocators"][allocator]["runtime"]["cpu_seconds"], index + 1)

    def test_reject_partial_matrix(self):
        sample = self.fixture()
        del sample["allocators"]["chordal"]
        with self.assertRaises(ValueError):
            rank.rank(sample)

    def test_reject_insufficient_samples(self):
        sample = self.fixture()
        sample["allocators"]["greedy"]["workloads"]["0"]["instructions"]["samples"] = [3, 3]
        with self.assertRaises(ValueError):
            rank.rank(sample)


if __name__ == "__main__":
    unittest.main()
