#!/usr/bin/env python3
# See https://factorcode.org/license.txt for BSD license.
"""Subprocess regressions for VM type errors and small callstacks (#1279/#1419)."""

import argparse
from pathlib import Path
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[2]
OPTIONS = None

PRELUDE = """
USING: continuations io kernel kernel.private literals math memory
prettyprint sequences system ;
IN: vm-stack-safety.tests
: depth ( n -- n )
    dup 0 = [ ] [ 1 - depth 1 + ] if ;
: depth-gc ( n -- n )
    dup 0 = [ compact-gc ] [ 1 - depth-gc 1 + ] if ;
: check-overflow ( error -- )
    2 head ${ KERNEL-ERROR ERROR-CALLSTACK-OVERFLOW } assert= ;
"""


class StackSafetyTests(unittest.TestCase):
    def run_factor(self, source, stack_kb=64):
        command = [
            str(OPTIONS.factor),
            "-i=" + str(OPTIONS.image),
            "-resource-path=" + str(ROOT),
            "-no-user-init",
            "-no-monitors",
            "-callstack=" + str(stack_kb),
            "-e=" + source,
        ]
        try:
            result = subprocess.run(
                command,
                # If the VM enters its low-level debugger, quit instead of
                # leaving a hung child. The missing success marker still fails.
                input="q\n",
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                errors="replace",
                timeout=OPTIONS.timeout,
            )
        except subprocess.TimeoutExpired as error:
            self.fail(f"VM timed out with a {stack_kb} KiB stack: {error.stdout!r}")
        self.assertEqual(result.returncode, 0, result.stdout[-12000:])
        self.assertIn("STACK-SAFETY-PASS", result.stdout, result.stdout[-12000:])
        return result.stdout

    def probe_depth(self, depth, collect=False, gc_word="compact-gc"):
        word = "depth-gc" if collect else "depth"
        return self.run_factor(
            PRELUDE.replace("[ compact-gc ]", "[ " + gc_word + " ]")
            + f"""
            [ {depth} {word} {depth} assert= "RETURNED" print ]
            [ check-overflow "OVERFLOW" print ] recover
            ! Recovery must leave the collector usable, not merely catch an
            ! error while stale GC state or broken guards remain in the VM.
            compact-gc
            40 2 + 42 assert=
            "STACK-SAFETY-PASS" print 0 exit
            """
        )

    def test_callstack_type_errors(self):
        self.run_factor(
            PRELUDE
            + """
            { "hello" 123 f } [
                [ callstack>array drop "missing type error" throw ]
                [ nip 2 head ${ KERNEL-ERROR ERROR-TYPE } assert= ] recover
            ] each
            get-callstack callstack>array drop
            compact-gc
            "STACK-SAFETY-PASS" print 0 exit
            """,
            stack_kb=1024,
        )

    def test_repeated_continuations(self):
        # The original #1419 reproducer, also exercised on a much smaller stack.
        for stack_kb in (64, 1024):
            with self.subTest(stack_kb=stack_kb):
                self.run_factor(
                    """
                    USING: io kernel math namespaces sequences system tools.test ;
                    10 [ "continuations" test ] times
                    test-failures get length 0 assert=
                    "STACK-SAFETY-PASS" print 0 exit
                    """,
                    stack_kb=stack_kb,
                )

    def recursion_limit(self):
        # Measure this VM/image's frame capacity. Compiler frame layouts and
        # the startup call chain differ between architectures and VM builds.
        low, high = 0, 8192
        self.assertIn("RETURNED", self.probe_depth(low))
        self.assertIn("OVERFLOW", self.probe_depth(high))
        while high - low > 1:
            middle = (low + high) // 2
            if "OVERFLOW" in self.probe_depth(middle):
                high = middle
            else:
                low = middle
        return low

    def test_gc_at_stack_boundary(self):
        low = self.recursion_limit()
        # Native GC frames need additional stack space. Try every depth around
        # the boundary: just testing a very deep recursion misses the narrow
        # range where GC used to fault while changing guard-page protection.
        print(f"\nMeasured recursion limit: {low}; probing GC boundary", flush=True)
        self.assertIn("RETURNED", self.probe_depth(0, collect=True))
        for depth in range(max(0, low - 256), low + 18):
            with self.subTest(depth=depth):
                self.probe_depth(depth, collect=True)

    def test_other_gc_entries(self):
        # Full and nursery collections enter through different VM methods.
        low = self.recursion_limit()
        for gc_word in ("minor-gc", "gc"):
            for depth in range(max(0, low - 48), low + 18, 4):
                with self.subTest(gc_word=gc_word, depth=depth):
                    self.probe_depth(depth, collect=True, gc_word=gc_word)

    def test_repeated_overflow_recovery(self):
        self.run_factor(
            PRELUDE
            + """
            10 [
                [ 100000 depth drop "missing overflow" throw ]
                [ check-overflow ] recover
                compact-gc
            ] times
            100 depth-gc 100 assert=
            "STACK-SAFETY-PASS" print 0 exit
            """
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--factor", type=Path, default=ROOT / "factor")
    parser.add_argument("--image", type=Path, default=ROOT / "factor.image")
    parser.add_argument("--timeout", type=float, default=60)
    OPTIONS, test_args = parser.parse_known_args()
    OPTIONS.factor = OPTIONS.factor.resolve()
    OPTIONS.image = OPTIONS.image.resolve()
    unittest.main(argv=[__file__, *test_args])
