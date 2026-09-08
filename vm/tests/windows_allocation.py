#!/usr/bin/env python3
# See https://factorcode.org/license.txt for BSD license.
"""Check the Windows VM's C++ allocation failure diagnostic (#2254)."""

import os
from pathlib import Path
import subprocess
import unittest


@unittest.skipUnless(os.name == "nt", "Windows VM allocation handler")
class WindowsAllocationTests(unittest.TestCase):
    def test_allocation_failure_before_vm_initialization(self):
        executable = Path(__file__).resolve().parents[2] / "windows-allocation-tests.exe"
        self.assertTrue(executable.is_file(), "Build with nmake /f Nmakefile test-vm first")
        result = subprocess.run(
            [str(executable)], capture_output=True, text=True,
            errors="replace", timeout=10,
        )
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("fatal_error: Out of memory in C++ allocation", result.stderr)
        self.assertNotIn("escaped without", result.stderr)


if __name__ == "__main__":
    unittest.main()
