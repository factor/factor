"""Shared runner contracts, without stock guest images or privileged services."""
import json
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
        code = 'import time; end=time.monotonic()+.4\nwhile time.monotonic()<end: pass'
        self.assertEqual(process.run([sys.executable, '-c', code], log,
                                    stall_seconds=.2, poll_seconds=.01), 0)

    def test_stall_reaps_owned_process(self):
        with self.assertRaisesRegex(RuntimeError, 'no CPU'):
            process.run([sys.executable, '-c', 'import time; time.sleep(30)'],
                        self.root / 'stall.log', stall_seconds=.1, poll_seconds=.02)

    def test_background_helpers_are_cleaned_without_changing_the_command_verdict(self):
        code = "import subprocess,sys; p=subprocess.Popen([sys.executable,'-c','import time; time.sleep(30)']); print(p.pid,flush=True)"
        log = self.root / 'background.log'
        self.assertEqual(process.run([sys.executable, '-c', code], log, poll_seconds=.01), 0)
        self.assertIn('HARNESS_CLEANUP_BACKGROUND_GROUP', log.read_text())
        pid = int(log.read_text().splitlines()[0])
        status = Path('/proc') / str(pid) / 'stat'
        import time
        for _ in range(200):
            if not status.exists() or status.read_text().rsplit(')', 1)[1].split()[0] == 'Z':
                break
            time.sleep(.01)
        else:
            self.fail('background helper survived cleanup')

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

    def test_adb_preserves_binary_upload_quoting_and_remote_failure(self):
        script = self.root / 'adb'
        script.write_text('#!/bin/sh\n'
                          'test "$1" = -s && test "$2" = emulator-fixture || exit 98\n'
                          'shift 2\n'
                          'test "$1" = shell && test "$2" = -T || exit 99\n'
                          'shift 2\nexec sh -c "$*"\n')
        script.chmod(0o755)
        transport = Transport({'kind': 'adb', 'argv': [str(script), '-s', 'emulator-fixture']}, self.root)
        payload = bytes(range(256)) * 1024
        log = self.root / 'adb.log'
        with tempfile.TemporaryFile() as stream:
            stream.write(payload)
            stream.seek(0)
            code = transport.run("printf '%s\\n' 'a b; $HOME'; cat; exit 7", log, stream)
        self.assertEqual(code, 7)
        self.assertEqual(log.read_bytes(), b'a b; $HOME\n' + payload)

    def test_adb_requires_an_explicit_device(self):
        profile = config.load('linux-x86-64', self.root)
        for argv in (['adb'], ['adb', '-s'], ['adb', '-s', '']):
            profile['transport'] = {'kind': 'adb', 'argv': argv}
            with self.assertRaisesRegex(ValueError, 'explicit -s'):
                config.validate(profile)
        profile['transport']['argv'] = ['adb', '-s', 'emulator-fixture']
        config.validate(profile)

    def test_cross_build_upload_resume_and_archive_binding(self):
        repo = self.root / 'cross-repo'
        repo.mkdir()
        subprocess.run(['git', 'init', '-q', str(repo)], check=True)
        (repo / 'probe.c').write_text('#include <stdio.h>\n#include <stdlib.h>\n'
            'int main(void) { const char *names[] = {"HOME", "TMPDIR", "XDG_CACHE_HOME"};\n'
            'for (int i=0; i<3; ++i) { const char *dir=getenv(names[i]); char path[4096];\n'
            'if (!dir || dir[0]!=\'/\') return 2;\n'
            'snprintf(path,sizeof(path),"%s/probe",dir); FILE *f=fopen(path,"w");\n'
            'if (!f) return 3; fclose(f); } puts("FACTOR_REOPEN_OK"); return 0; }\n')
        (repo / 'test.mk').write_text('factor-executable:\n\t$(CC) -o factor probe.c\n'
            'factor-ffi-test:\n\t$(CC) -shared -fPIC -o libfactor-ffi-test.so probe.c\n'
            'factor-lib:\n\t$(CC) -shared -fPIC -o libfactor.so probe.c\n')
        tests = repo / 'vm' / 'tests'
        tests.mkdir(parents=True)
        (tests / 'Makefile.ieee-float').write_text(
            'all:\n\tmkdir -p $(BUILD_DIR)\n\t$(CC) -o $(BUILD_DIR)/probe probe.c\n'
            'print-programs:\n\t@echo $(BUILD_DIR)/probe\n')
        subprocess.run(['git', 'add', '.'], cwd=repo, check=True)
        subprocess.run(['git', '-c', 'user.name=Harness test', '-c',
                        'user.email=harness@example.invalid', 'commit', '-qm', 'fixture'], cwd=repo, check=True)
        ssh = self.root / 'cross-ssh'
        ssh.write_text('#!/bin/sh\nexec sh -c "$1"\n')
        ssh.chmod(0o755)
        guest = self.root / 'cross-guest'
        guest.mkdir()
        seed = self.root / 'cross-seed.image'
        seed.write_bytes(b'fixture seed')
        profile = {'id': 'cross-fixture', 'assets': str(self.root),
                   'transport': {'kind': 'ssh', 'argv': [str(ssh)]}, 'work_root': str(guest),
                   'build': {'host': True, 'config': 'fixture', 'make': 'make', 'env': {'CC': 'cc'},
                             'args': ['-f', 'test.mk'],
                             'targets': ['factor-executable', 'factor-ffi-test', 'factor-lib'],
                             'artifacts': ['factor', 'libfactor-ffi-test.so', 'libfactor.so']},
                   'execution': {'directories': {'HOME': '.home', 'TMPDIR': '.tmp', 'XDG_CACHE_HOME': '.cache'}}}
        output = self.root / 'cross-run'
        selected = ('build', 'numeric', 'reopen')
        state = runner.execute(profile, output, seed, stages=selected, repo=repo)
        self.assertEqual(state['status'], 'partial')
        self.assertEqual((output / 'build-source' / 'factor').read_bytes(),
                         (Path(state['directory']) / 'factor').read_bytes())
        self.assertEqual((output / 'build-source' / 'probe.c').read_bytes(), (repo / 'probe.c').read_bytes())
        for name in ('.home/probe', '.tmp/probe', '.cache/probe', 'libfactor.so'):
            self.assertTrue((Path(state['directory']) / name).is_file())
        receipt = (output / 'build-1.json').read_bytes()
        state = runner.execute(profile, output, seed, resume=True, stages=selected, repo=repo)
        self.assertEqual(state['status'], 'partial')
        self.assertEqual((output / 'build-1.json').read_bytes(), receipt)
        with (output / stages.BUILD_ARCHIVE).open('ab') as stream:
            stream.write(b'changed')
        with self.assertRaisesRegex(ValueError, 'cross-build artifacts changed'):
            runner.execute(profile, output, seed, resume=True, stages=selected, repo=repo)

    def test_serial_backpressure_retains_partial_send_offsets(self):
        from unittest.mock import Mock
        connection = Mock()
        connection.send.side_effect = [socket.timeout(), 2, 2]
        transport = Transport({'kind': 'serial'}, self.root)
        transport.send(connection, b'abcd')
        self.assertEqual([bytes(call.args[0]) for call in connection.send.call_args_list],
                         [b'abcd', b'abcd', b'cd'])

    def test_serial_upload_through_a_real_shell(self):
        import hashlib
        import io
        import time
        payload = bytes(range(256)) * 1024
        binary = self.root / 'console'
        subprocess.run(['cc', '-std=c11', '-Wall', '-Wextra', '-Werror',
                        str(config.ROOT / 'harness' / 'console.c'), '-o', str(binary)], check=True)
        with socket.socket() as listener:
            listener.bind(('127.0.0.1', 0))
            port = listener.getsockname()[1]
        console = subprocess.Popen([str(binary), '127.0.0.1', str(port)])
        try:
            for _ in range(100):
                try:
                    with socket.create_connection(('127.0.0.1', port), timeout=.1):
                        break
                except OSError:
                    if console.poll() is not None:
                        self.fail('guest console exited before accepting connections')
                    time.sleep(.01)
            transport = Transport({'kind': 'serial', 'host': '127.0.0.1', 'port': port,
                                   'binary_stdin': True}, self.root)
            result = transport.run('sha256sum; sh -c "exit 7"', self.root / 'upload.log', io.BytesIO(payload))
        finally:
            console.terminate()
            console.wait()
        self.assertEqual(result, 7)
        self.assertIn(hashlib.sha256(payload).hexdigest(), (self.root / 'upload.log').read_text())

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

    def test_early_guest_failure_cleans_up_without_an_unreachable_shutdown(self):
        from harness.guest import Guest
        from unittest.mock import Mock
        transport = Mock()
        guest = Guest({'argv': ['fixture']}, self.root, transport)
        guest.child = Mock(returncode=-15)
        guest.child.poll.return_value = None
        guest.log = (self.root / 'emulator.log').open('wb')
        with patch.object(process, 'stop', return_value=False):
            guest.__exit__(RuntimeError, RuntimeError('boot failed'), None)
        transport.run.assert_not_called()
        self.assertTrue(guest.closed['forced'])
        self.assertIn('before readiness', guest.closed['error'])
        guest.__exit__(None, None, None)  # Closing twice preserves the first receipt.
        self.assertTrue(guest.closed['forced'])

    def test_boot_console_consumes_prompts_in_order(self):
        from harness.guest import Guest
        from unittest.mock import Mock
        address = self.root / 'boot.sock'
        (self.root / 'console.log').write_text('first? second?')
        replies = []
        with socket.socket(socket.AF_UNIX) as listener:
            listener.bind(str(address))
            listener.listen()

            def console():
                for _ in range(2):
                    with listener.accept()[0] as connection:
                        value = b''
                        while chunk := connection.recv(128):
                            value += chunk
                        replies.append(value)

            thread = threading.Thread(target=console)
            thread.start()
            transport = Transport({'kind': 'ssh', 'argv': []}, self.root)
            guest = Guest({'console_steps': [{'expect': 'first?', 'send': 'one\r'},
                                            {'expect': 'second?', 'send': 'two\r'}]}, self.root, transport)
            guest.child = Mock()
            guest.child.poll.return_value = None
            guest.console_path = address
            guest.boot_console()
            thread.join()
        self.assertEqual(replies, [b'one\r', b'two\r'])

    def test_vnc_actions_cover_first_boot_pointer_and_keyboard_input(self):
        from harness.transport import vnc_actions
        from unittest.mock import Mock
        client = Mock()
        connection = Mock()
        connection.__enter__ = Mock(return_value=client)
        connection.__exit__ = Mock(return_value=False)
        actions = [{'move': [12, 34]}, {'click': 1}, {'key': 'tab'},
                   {'text': 'ok\n'}, {'pause': .01}]
        with patch('vncdotool.api.connect', return_value=connection), \
                patch('vncdotool.api.shutdown') as shutdown, patch('time.sleep') as sleep:
            vnc_actions('127.0.0.1::5900', actions)
        client.mouseMove.assert_called_once_with(12, 34)
        client.mousePress.assert_called_once_with(1)
        self.assertEqual([call.args[0] for call in client.keyPress.call_args_list],
                         ['tab', 'o', 'k', 'enter'])
        sleep.assert_called_once_with(.01)
        shutdown.assert_called_once_with()

    def test_all_profiles_render_without_external_assets_or_jobs(self):
        names = config.profiles()
        self.assertGreaterEqual(len(names), 47)
        for name in names:
            profile = config.load(name, self.root)
            rendered = runner.plan(profile)
            self.assertEqual(set(rendered['stages']), set(stages.STAGES))
            self.assertIsNone(rendered['elapsed_timeout'])

    def test_android_profiles_ship_their_openssl_runtime(self):
        for name, abi in (('android-arm-64', 'arm64-v8a'),):
            profile = config.load(name, self.root)
            self.assertEqual(profile['build']['env']['ANDROID_ABI'], abi)
            self.assertIn('android-runtime-libs', profile['build']['targets'])
            self.assertIn('android-libs', profile['build']['artifacts'])
            self.assertIn('android-libs/libcrypto.so', profile['artifacts'])
            self.assertIn('android-libs/libssl.so', profile['artifacts'])
            self.assertIn('android-libs/libsqlite3.so', profile['artifacts'])
            self.assertEqual(profile['execution']['directories']['LD_LIBRARY_PATH'],
                             'android-libs')

    def test_nested_closure_requires_both_layers(self):
        good = dict(forced=False, error=None, shutdown_exit=0, emulator_exit=0)
        self.assertTrue(runner.closure_passed(good, {}))
        bad = dict(good, forced=True)
        inner = dict(good, emulator_exit=1, outer=bad)
        config = {'success_exit': 1, 'outer': {'guest': {}}}
        self.assertFalse(runner.closure_passed(inner, config))
        self.assertFalse(runner.closure_passed(None, {'argv': ['qemu']}))

    def test_real_source_snapshot_stage_resume_and_artifact_binding(self):
        repo = self.root / 'repo'
        repo.mkdir()
        subprocess.run(['git', 'init', '-q', str(repo)], check=True)
        (repo / 'source.txt').write_text('original')
        subprocess.run(['git', 'add', '.'], cwd=repo, check=True)
        subprocess.run(['git', '-c', 'user.name=Harness test', '-c',
                        'user.email=harness@example.invalid', 'commit', '-qm', 'fixture'], cwd=repo, check=True)
        seed = self.root / 'boot.image'
        seed.write_bytes(b'fixture seed')
        profile = {'id': 'fixture', 'assets': str(self.root), 'transport': {'kind': 'local'}}

        def fixture_commands(profile, directory):
            import shlex
            prefix = 'cd ' + shlex.quote(directory) + '; '
            commands = {name: prefix + 'true' for name in stages.STAGES}
            commands['build'] = prefix + 'touch factor libfactor-ffi-test.so'
            commands['bootstrap'] = prefix + 'echo fixture > factor.image'
            commands['reopen'] = 'echo FACTOR_REOPEN_OK'
            commands['core'] = 'echo QEMU_CORE_FAILURES 0'
            for name in ('compiler', 'io', 'ui'):
                commands[name] = "echo 'Unit Test: fixture'"
            return commands

        output = self.root / 'run'
        with patch.object(runner, 'commands', side_effect=fixture_commands):
            state = runner.execute(profile, output, seed, stages=('build',), repo=repo)
            self.assertEqual(state['status'], 'partial')
            original = (output / 'build-1.json').read_bytes()
            state = runner.execute(profile, output, seed, resume=True, repo=repo)
            self.assertEqual(state['status'], 'pass')
            self.assertEqual(original, (output / 'build-1.json').read_bytes())
            (Path(state['directory']) / 'factor.image').write_bytes(b'changed')
            with self.assertRaisesRegex(ValueError, 'artifacts changed'):
                runner.execute(profile, output, seed, resume=True, repo=repo)
            self.assertEqual(json.loads((output / 'run.json').read_text())['status'], 'fail')
            (repo / 'source.txt').write_text('dirty')
            with self.assertRaisesRegex(ValueError, 'commit tracked changes'):
                runner.source_identity(repo)


if __name__ == '__main__':
    unittest.main()
