#!/usr/bin/env python3
"""Windows VM startup diagnostics before a VM is available."""
import os
from pathlib import Path
import subprocess
import shutil
import tempfile
import unittest


@unittest.skipUnless(os.name == "nt", "Windows VM services")
class WindowsServicesTests(unittest.TestCase):
    def test_image_path_in_dotted_directory(self):
        executable = Path(__file__).resolve().parents[2] / "windows-services-tests.exe"
        with tempfile.TemporaryDirectory(suffix=".directory") as directory:
            for name in ("service.exe", "service"):
                with self.subTest(name=name):
                    copy = Path(directory) / name
                    shutil.copy2(executable, copy)
                    expected = str(Path(directory) / "service.image")
                    result = subprocess.run([str(copy), "image-path", expected],
                                            capture_output=True, text=True, timeout=10)
                    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_early_fatal_error(self):
        executable = Path(__file__).resolve().parents[2] / "windows-services-tests.exe"
        for mode, message in (("fatal-before-init", "Before VM initialization"),
                              ("fatal-after-init", "Before VM registration"),
                              ("segment-overflow", "Windows segment size overflow"),
                              ("guard-overflow", "Invalid Windows segment size")):
            with self.subTest(mode=mode):
                result = subprocess.run([str(executable), mode], capture_output=True,
                                        text=True, errors="replace", timeout=10)
                self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                self.assertIn("fatal_error: " + message, result.stderr)


if __name__ == "__main__":
    unittest.main()
