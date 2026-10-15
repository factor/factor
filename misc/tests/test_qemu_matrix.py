"""Acceptance policy regressions without booting guests or altering receipts."""
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location(
    'qemu_matrix', Path(__file__).resolve().parents[1] / 'qemu/matrix.py')
matrix = importlib.util.module_from_spec(spec)
spec.loader.exec_module(matrix)


class CppAcceptanceTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.bundle_dir = self.root / 'loongarch'
        self.bundle_dir.mkdir()
        self.revision = 'abcdef1234'
        self.cpp = {stage: {'status': 'pass', 'exit_code': 0,
                            'source_revision': self.revision}
                    for stage in ('compiler', 'io')}

    def report(self, variants, expected_revision=None):
        bundle = self.bundle_dir / 'completed-prefixes-review.json'
        bundle.write_text(json.dumps({'variants': variants}))
        review = {'all_required_full_prefixes_pass': True,
                  'bundle_sha256': hashlib.sha256(bundle.read_bytes()).hexdigest()}
        (self.bundle_dir / 'root-full-prefix-complete-review.json').write_text(json.dumps(review))
        with patch.object(matrix, 'foundation', return_value=[]):
            rows = matrix.rows(self.root, expected_revision or self.revision)
        return next(row for row in rows if row['os'] == 'linux' and row['arch'] == 'loongarch64')

    def test_cpp_only_bundle_does_not_require_zig(self):
        row = self.report({'cpp': self.cpp})
        self.assertEqual(row['vm_policy']['required'], ['cpp'])
        self.assertEqual(row['cpp']['compiler'], 'pass')
        self.assertEqual(row['cpp']['io'], 'pass')
        self.assertNotEqual(row['zig']['compiler'], 'pass')
        self.assertNotEqual(row['zig']['io'], 'pass')

    def test_optional_zig_failure_is_preserved(self):
        zig = {'compiler': {'status': 'fail', 'exit_code': 1, 'source_revision': self.revision}}
        row = self.report({'cpp': self.cpp, 'zig': zig})
        self.assertEqual(row['cpp']['compiler'], 'pass')
        self.assertEqual(row['zig']['compiler'], 'fail')

    def test_cpp_gate_still_requires_successful_exit(self):
        cpp = dict(self.cpp, compiler=dict(self.cpp['compiler'], exit_code=1))
        with self.assertRaisesRegex(ValueError, 'incomplete cpp/compiler'):
            self.report({'cpp': cpp})

    def test_historical_uppercase_cpp_pass_is_accepted(self):
        cpp = {stage: dict(detail, status='PASS') for stage, detail in self.cpp.items()}
        row = self.report({'cpp': cpp})
        self.assertEqual(row['cpp']['compiler'], 'pass')
        self.assertEqual(row['cpp']['io'], 'pass')

    def test_optional_unverified_pass_is_not_promoted(self):
        for value in ('pass', 'passed', 'PASS'):
            with self.subTest(status=value):
                zig = {'compiler': {'status': value, 'source_revision': self.revision}}
                row = self.report({'cpp': self.cpp, 'zig': zig})
                self.assertNotEqual(row['zig']['compiler'], 'pass')
                self.assertEqual(row['acceptance_provenance']['variants']['zig'], zig)

    def test_frozen_cpp_pass_does_not_certify_later_revision(self):
        row = self.report({'cpp': self.cpp}, '123456abcd')
        self.assertEqual(row['cpp']['compiler'], 'stale')
        self.assertEqual(row['cpp']['io'], 'stale')


if __name__ == '__main__':
    unittest.main()
