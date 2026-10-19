#!/usr/bin/env python3
"""Keep startup-relative image and resource paths stable across directory changes."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
OPTIONS = None


class ResourcePathTests(unittest.TestCase):
    def test_relative_startup_paths(self):
        with tempfile.TemporaryDirectory(prefix="factor-resources-") as directory:
            root = Path(directory)
            # A real adjacent executable/image also exercises a child without -i.
            shutil.copy2(OPTIONS.factor.resolve(), root / "factor")
            shutil.copy2(OPTIONS.image.resolve(), root / "factor.image")
            for name in ("core", "basis", "extra"):
                (root / name).symlink_to(OPTIONS.resources.resolve() / name)
            shutil.copy2(OPTIONS.resources / "LICENSE.txt", root / "LICENSE.txt")
            child = ('-e=USING: io.files io.encodings.utf8 io kernel ; '
                     '"resource:LICENSE.txt" utf8 file-contents drop "CHILD-PASS" print')
            code = '''USING: arrays accessors calendar io io.files io.encodings.utf8 io.launcher
                io.pathnames kernel locals system ;
                [let
                    "resource:LICENSE.txt" utf8 file-contents :> license
                    [
                        "resource:LICENSE.txt" utf8 file-contents license =
                        [ "resource root changed with cwd" throw ] unless
                        image-path absolute-path?
                        [ "image path is still relative" throw ] unless
                        vm-path "-no-user-init" "-no-monitors" __CHILD_COMMAND__ 4array
                        <process> swap >>command 5 seconds >>timeout
                        process-contents "CHILD-PASS\\n" =
                        [ "bare child lost adjacent resources" throw ] unless
                    ] with-test-directory
                ] "RESOURCE-PATH-PASS" print'''.replace("__CHILD_COMMAND__", json.dumps(child))
            for option in ([], ["-resource-path=."]):
                with self.subTest(option=option):
                    result = subprocess.run(
                        [str(root / "factor"), "-i=factor.image", "-no-user-init",
                         "-no-monitors", *option, "-e=" + code], cwd=root,
                        text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                        timeout=60)
                    self.assertEqual(result.returncode, 0, result.stdout)
                    self.assertIn("RESOURCE-PATH-PASS", result.stdout.splitlines())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--factor", type=Path, default=ROOT / "factor")
    parser.add_argument("--image", type=Path, default=ROOT / "factor.image")
    parser.add_argument("--resources", type=Path, default=ROOT)
    OPTIONS, rest = parser.parse_known_args()
    unittest.main(argv=[__file__, *rest])
