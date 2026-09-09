#!/usr/bin/env python3
"""Windows VM startup diagnostics before a VM is available."""
import os
from pathlib import Path
import subprocess
import unittest


@unittest.skipUnless(os.name == "nt", "Windows VM services")
class WindowsServicesTests(unittest.TestCase):
    def test_early_fatal_error(self):
        executable = Path(__file__).resolve().parents[2] / "windows-services-tests.exe"
        for mode, message in (("fatal-before-init", "Before VM initialization"),
                              ("fatal-after-init", "Before VM registration")):
            with self.subTest(mode=mode):
                result = subprocess.run([str(executable), mode], capture_output=True,
                                        text=True, errors="replace", timeout=10)
                self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                self.assertIn("fatal_error: " + message, result.stderr)


if __name__ == "__main__":
    unittest.main()
