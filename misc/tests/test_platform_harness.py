"""Shared runner contracts, without stock guest images or privileged services."""
from contextlib import contextmanager
import io
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import tempfile
import threading
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from harness import config, process, runner, stages
from harness.transport import Transport


class HarnessTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def test_profile_merge_replaces_lists_without_mutating_defaults(self):
        defaults = {'build': {'args': ['old'], 'jobs': 1}}
        self.assertEqual(config.merge(defaults, {'build': {'args': ['new']}}),
                         {'build': {'args': ['new'], 'jobs': 1}})
        self.assertEqual(defaults['build']['args'], ['old'])

    def test_test_markers_and_exit_status_are_required(self):
        for name in ('compiler', 'io', 'ui'):
            self.assertTrue(stages.passed(name, 0, b'Unit Test: { 1 }\n'))
            for code, log in [(1, b'Unit Test:'), (0, b''),
                              (0, b'Unit Test:\n--> test failed!'),
                              (0, b'Unit Test:\n==== SKIPPED TESTS: 1\n')]:
                self.assertFalse(stages.passed(name, code, log))
        self.assertFalse(stages.passed('core', 0, b'QEMU_CORE_FAILURES 1'))
        self.assertTrue(stages.passed('core', 0, b'QEMU_CORE_FAILURES 0'))

    def test_activity_keeps_quiet_computation_alive(self):
        log = self.root / 'cpu.log'
        code = 'import time; end=time.monotonic()+.2\nwhile time.monotonic()<end: pass'
        self.assertEqual(process.run([sys.executable, '-c', code], log,
                                    stall_seconds=.05, poll_seconds=.01), 0)

    def test_stall_reaps_owned_process(self):
        with self.assertRaisesRegex(RuntimeError, 'no CPU'):
            process.run([sys.executable, '-c', 'import time; time.sleep(30)'],
                        self.root / 'stall.log', stall_seconds=.1, poll_seconds=.02)

    def test_atomic_write_retains_previous_receipt_on_replace_failure(self):
        path = self.root / 'receipt.json'
        process.write_json(path, {'status': 'running'})
        with patch('os.replace', side_effect=OSError('disk full')):
            with self.assertRaises(OSError):
                process.write_json(path, {'status': 'pass'})
        self.assertEqual(json.loads(path.read_text()), {'status': 'running'})

    def test_ssh_preserves_shell_quoting_and_stdin(self):
        script = self.root / 'ssh'
        script.write_text('#!/bin/sh\nexec sh -c "$1"\n')
        script.chmod(0o755)
        transport = Transport({'kind': 'ssh', 'argv': [str(script)]}, self.root)
        with (self.root / 'input').open('wb') as stream:
            stream.write(b'payload\n')
        with (self.root / 'input').open('rb') as stream:
            code = transport.run("printf '%s\\n' 'a b; $HOME'; cat; exit 7", self.root / 'ssh.log', stream)
        self.assertEqual(code, 7)
        self.assertEqual((self.root / 'ssh.log').read_text(), 'a b; $HOME\npayload\n')

    def test_serial_requires_its_own_complete_exit_marker(self):
        address = str(self.root / 'console.sock')
        with socket.socket(socket.AF_UNIX) as listener:
            listener.bind(address)
            listener.listen()

            def console():
                with listener.accept()[0] as connection:
                    data = connection.recv(8192)
                    import re
                    token = re.search(rb'FACTOR_EXIT_([0-9a-f]+)', data)[1]
                    connection.sendall(b'FACTOR_EXIT_old 0\noutput\nFACTOR_EXIT_' + token + b' ')
                    connection.sendall(b'3\n')

            thread = threading.Thread(target=console)
            thread.start()
            transport = Transport({'kind': 'serial', 'socket': address}, self.root)
            self.assertEqual(transport.run('false', self.root / 'serial.log'), 3)
            thread.join()

    def test_failed_attempt_is_retained_and_resume_detects_changed_log(self):
        transport = Transport({'kind': 'local'}, self.root)
        binding = {'source': 'one'}
        with self.assertRaisesRegex(RuntimeError, 'build failed'):
            runner.attempt(self.root, 'build', 'exit 4', transport, binding)
        record = runner.attempt(self.root, 'build', 'true', transport, binding)
        self.assertTrue(runner.reusable(self.root, record, binding))
        self.assertEqual(json.loads((self.root / 'build-1.json').read_text())['exit_code'], 4)
        (self.root / 'build-2.log').write_text('changed')
        with self.assertRaisesRegex(ValueError, 'changed evidence'):
            runner.reusable(self.root, record, binding)


if __name__ == '__main__':
    unittest.main()
