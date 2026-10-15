#!/usr/bin/env python3
"""Admission metadata must survive storage errors without starting a job."""
import errno
import importlib.util
import json
from pathlib import Path
import tempfile
import types
import unittest
from unittest import mock


spec = importlib.util.spec_from_file_location(
    'host_job', Path(__file__).resolve().parents[1] / 'qemu' / 'host-job.py')
host_job = importlib.util.module_from_spec(spec)
spec.loader.exec_module(host_job)


class HostJobMetadataTests(unittest.TestCase):
    def test_failed_update_preserves_previous_receipt(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'admission.json'
            previous = {'admitted': True, 'demand_bytes': 8 * 1024**3}
            host_job.write_json(path, previous)
            with mock.patch.object(host_job.os, 'replace',
                                   side_effect=OSError(errno.ENOSPC, 'disk full')):
                with self.assertRaises(OSError):
                    host_job.write_json(path, {'admitted': False})
            self.assertEqual(json.loads(path.read_text()), previous)
            self.assertEqual(list(Path(directory).iterdir()), [path])
            self.assertEqual(path.stat().st_mode & 0o777, 0o600)

    def test_only_explicit_waiting_receipt_releases_reservation(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / 'admission.json'
            for content in ('', '{', '{}', 'null', '[]', '{"admitted": true}'):
                path.write_text(content)
                self.assertFalse(host_job.known_waiting(path), content)
            path.write_text('{"admitted": false}')
            self.assertTrue(host_job.known_waiting(path))

    def test_storage_failure_waits_before_invoking_command(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            record = {'profile': 'guest-controller', 'argv': ['owned-command'],
                      'cwd': directory, 'env': {}}
            host_job.write_json(root / 'command.json', record)
            calls = []

            def admission(*args):
                calls.append('admission')
                if calls == ['admission']:
                    raise OSError(errno.ENOSPC, 'disk full')
                return True

            def command(*args, **kwargs):
                self.assertEqual(calls, ['admission', 'sleep', 'admission'])
                return types.SimpleNamespace(returncode=0)

            with mock.patch.object(host_job, 'BASE', root), \
                    mock.patch.object(host_job, 'admission_check', side_effect=admission), \
                    mock.patch.object(host_job.time, 'sleep', side_effect=lambda _: calls.append('sleep')), \
                    mock.patch.object(host_job.subprocess, 'run', side_effect=command), \
                    self.assertRaises(SystemExit) as result:
                host_job.run(directory)
            self.assertEqual(result.exception.code, 0)
            self.assertEqual((root / 'exitcode').read_text(), '0\n')


if __name__ == '__main__':
    unittest.main()
