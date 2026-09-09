#!/usr/bin/env python3
"""Verify failure propagation without changing the source tree or its library."""
import argparse
import hashlib
import json
from pathlib import Path
import platform
import subprocess
import sys
import tempfile


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def overlay(source, target):
    target.mkdir()
    for entry in source.iterdir():
        (target / entry.name).symlink_to(entry, target_is_directory=entry.is_dir())


def replace_file(root, relative, content):
    """Materialize only the path being changed; never write through a symlink."""
    path = root
    parts = Path(relative).parts
    for part in parts[:-1]:
        path /= part
        if path.is_symlink():
            original = path.resolve()
            path.unlink()
            path.mkdir()
            for entry in original.iterdir():
                (path / entry.name).symlink_to(entry, target_is_directory=entry.is_dir())
        elif not path.exists():
            path.mkdir()
    path /= parts[-1]
    if path.is_symlink():
        path.unlink()
    path.write_text(content)
    return path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--factor", type=Path, required=True)
    parser.add_argument("--image", type=Path, required=True)
    parser.add_argument("--cc", required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--allow-concurrent-root-changes", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    library_name = {"Darwin": "libfactor-ffi-test.dylib",
                    "Windows": "libfactor-ffi-test.dll"}.get(
                        platform.system(), "libfactor-ffi-test.so")
    protected = [root / library_name, root / "vm/ffi_test.c",
                 root / "vm/ffi_test_varargs.c",
                 root / "basis/compiler/tests/alien-varargs.factor",
                 root / "basis/compiler/tests/varargs/printf.factor"]
    before = {path: digest(path) for path in protected}
    summary = []

    def execute(name, command, cwd, required):
        result = subprocess.run(list(map(str, command)), cwd=cwd,
                                capture_output=True, text=True, timeout=240)
        text = result.stdout + result.stderr
        (args.output / (name + ".log")).write_text(text)
        if result.returncode != 1:
            raise AssertionError(f"{name}: expected exit 1, got {result.returncode}")
        for needle in required:
            if needle not in text:
                raise AssertionError(f"{name}: expected diagnostic {needle!r} missing")
        line = f"{name}: exit 1; expected diagnostic verified"
        summary.append(line)
        print(line, flush=True)

    with tempfile.TemporaryDirectory(prefix="factor-varargs-negative-") as temporary:
        temporary = Path(temporary)
        for name in ("factor-assertion", "missing-fixture", "required-small"):
            case_root = temporary / name
            overlay(root, case_root)
            # The helper locates its root using __file__.resolve(); copy it.
            replace_file(case_root, ".github/check-arm64-varargs.py",
                         (root / ".github/check-arm64-varargs.py").read_text())
            # Its compiler output must not follow the original library symlink.
            (case_root / library_name).unlink(missing_ok=True)
            if name == "factor-assertion":
                relative = ".github/arm64-varargs-tests.factor"
                runner = (root / relative).read_text()
                start = runner.index('"resource:.github/arm64-varargs-coverage.factor" run-file')
                start = runner.index("\n", start) + 1
                end = runner.index("test-failures get empty?", start)
                # Keep the actual coverage and exit-status code, but run one
                # intentional failure instead of repeating positive suites.
                replace_file(case_root, relative, runner[:start] +
                             '"resource:negative-assertion.factor" run-test-file\n\n' +
                             runner[end:])
                replace_file(case_root, "negative-assertion.factor",
                             'USING: tools.test ;\n'
                             '{ "intentional-varargs-ci-failure" } [ f ] unit-test\n')
                diagnostic = ["intentional-varargs-ci-failure", "CalledProcessError"]
            elif name == "missing-fixture":
                relative = "vm/ffi_test.c"
                source = (root / relative).read_text()
                marker = '#include "ffi_test_varargs.c"'
                assert marker in source
                replace_file(case_root, relative, source.replace(marker, ""))
                diagnostic = ["va_c_controls", "CalledProcessError"]
            else:
                relative = "vm/ffi_test_varargs.c"
                source = (root / relative).read_text()
                marker = "int va_small_available(void) { return 1; }"
                assert marker in source
                replace_file(case_root, relative, source.replace(marker,
                             "int va_small_available(void) { return 0; }"))
                diagnostic = ["va_small_available", "CalledProcessError"]
            execute(name, [sys.executable, case_root / ".github/check-arm64-varargs.py",
                          "--cc", args.cc, "--factor", args.factor.resolve(),
                          "--image", args.image.resolve(), "--require-small"],
                    case_root, diagnostic)

        # Exercise the subprocess harness against actual printf with only the
        # expected C return count changed. This is distinct from wrong bytes.
        case_root = temporary / "printf-return-count"
        overlay(root, case_root)
        relative = "basis/compiler/tests/varargs/printf.factor"
        source = (root / relative).read_text()
        assert "33 =" in source
        replace_file(case_root, relative, source.replace("33 =", "34 ="))
        harness = root / "reference/arm64-varargs-20260908/check-printf.py"
        execute("printf-return-count", [sys.executable, harness,
                "--factor", args.factor.resolve(), "--image", args.image.resolve(),
                "--root", case_root], root,
                ["printf returned the wrong output length", "printf regression"])

        if platform.system() != "Windows":
            # A tiny stand-in isolates the parent's byte/status checks from
            # the real native return-count check immediately above.
            for name, output, status in (
                    ("printf-wrong-bytes", "wrong output\n", 0),
                    ("printf-child-error", "value:-42:  1.250:-1234567890123\n", 1)):
                fake = temporary / name
                fake.write_text("#!/usr/bin/env python3\nimport sys\n"
                                f"sys.stdout.write({output!r})\n"
                                f"raise SystemExit({status})\n")
                fake.chmod(0o755)
                execute(name, [sys.executable, harness, "--factor", fake,
                        "--image", args.image.resolve(), "--root", root], root,
                        ["printf regression", f"exit={status}"])

    after = {path: digest(path) for path in protected}
    changed = [str(path.relative_to(root)) for path in protected if before[path] != after[path]]
    (args.output / "root-hashes.json").write_text(json.dumps({
        str(path.relative_to(root)): {"before": before[path], "after": after[path]}
        for path in protected}, indent=2) + "\n")
    if changed:
        if not args.allow_concurrent_root_changes:
            raise AssertionError("Protected root files changed: " + ", ".join(changed))
        summary.append("Concurrent root edits observed: " + ", ".join(changed))
        summary.append("Compiler outputs and edits used isolated overlay paths")
    else:
        summary.append("Root fixture source and library SHA-256 values unchanged")
    (args.output / "SUMMARY.txt").write_text("\n".join(summary) + "\n")
    print(summary[-1], flush=True)


if __name__ == "__main__":
    main()
