#!/usr/bin/env python3
import ctypes
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]

class RuntimeLibraryProbe(unittest.TestCase):
    def test_runtime_libraries(self):
        source = Path(os.environ.get('FACTOR_BUILD_SCRIPT', ROOT / 'build.sh')).read_text()
        probe = re.search(r'(?ms)^check_library_exists\(\) \{.*?^\}', source).group()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            fixture = root / 'fixture.c'
            fixture.write_text('int fixture(void) { return 47; }\n')
            cc = os.environ.get('CC', 'cc')
            subprocess.run([cc, '-shared', '-fPIC', str(fixture), '-o', str(root / 'libfactor-probe.so.1')], check=True)
            self.assertEqual(ctypes.CDLL(str(root / 'libfactor-probe.so.1')).fixture(), 47)
            fixture.write_text('extern int absent_dependency(void); int fixture(void) { return absent_dependency(); }\n')
            subprocess.run([cc, '-shared', '-fPIC', str(fixture), '-o', str(root / 'libfactor-broken.so.1')], check=True)
            with self.assertRaises(OSError):
                ctypes.CDLL(str(root / 'libfactor-broken.so.1'))
            env = dict(os.environ, LD_LIBRARY_PATH=directory, CC=cc, OS='linux', ECHO='echo')
            for name, soname, expected in [('factor-probe', 'libfactor-probe.so.1', 'found.'),
                                         ('factor-absent', 'libfactor-absent.so.1', 'not found.'),
                                         ('factor-broken', 'libfactor-broken.so.1', 'not found.')]:
                with self.subTest(name=name):
                    command = probe + '\ncheck_ret() { :; }\ncheck_library_exists "$1" "$2"'
                    run = subprocess.run(['bash', '-c', command, 'probe', name, soname], env=env,
                                         cwd=directory, capture_output=True, text=True, timeout=30)
                    self.assertEqual(run.stdout, f'Checking for library {name}...{expected}\n')
            bad = dict(env, CC='/nonexistent/compiler')
            run = subprocess.run(['bash', '-c', probe + '\ncheck_library_exists factor-probe libfactor-probe.so.1'],
                                 env=bad, cwd=directory, capture_output=True, text=True, timeout=30)
            self.assertNotEqual(run.returncode, 0)
            self.assertIn('unable to build runtime library probe.', run.stdout)

if __name__ == '__main__':
    unittest.main()
