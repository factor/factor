#!/usr/bin/env python3
"""Reject code heaps whose Windows x64 unwind end RVA would overflow."""

import os
from pathlib import Path
import platform
import subprocess
import unittest


@unittest.skipUnless(os.name == "nt" and platform.machine().lower() in
                     ("amd64", "x86_64"), "Windows x64 unwind RVAs")
class WindowsCodeHeapTests(unittest.TestCase):
    def test_unrepresentable_heap_end(self):
        executable = Path(__file__).resolve().parents[2] / "windows-code-heap-tests.exe"
        self.assertTrue(executable.is_file(), "Build with nmake /f Nmakefile test-vm first")
        for mode in ("exact", "rounded"):
            with self.subTest(mode=mode):
                result = subprocess.run(
                    [str(executable), mode], capture_output=True, text=True,
                    errors="replace", timeout=10,
                )
                if result.returncode == 77:
                    self.skipTest("Probe was built for a different architecture")
                self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                self.assertIn("fatal_error: Heap too large", result.stderr)


if __name__ == "__main__":
    unittest.main()
