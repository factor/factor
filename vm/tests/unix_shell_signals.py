#!/usr/bin/env python3
"""Exercise #1595 and console interruption from #1573 in private PTY sessions."""

import argparse
import errno
import os
from pathlib import Path
import pty
import select
import shlex
import signal
import time
import unittest


ROOT = Path(__file__).resolve().parents[2]
OPTIONS = None


class Terminal:
    def __init__(self, arguments):
        self.pid, self.fd = pty.fork()
        if self.pid == 0:
            os.chdir(ROOT)
            os.execv(str(OPTIONS.factor), arguments)
        self.output = b""

    def send(self, data):
        os.write(self.fd, data)

    def read_until(self, marker, timeout=20):
        start = len(self.output)
        deadline = time.monotonic() + timeout
        while marker not in self.output[start:]:
            if time.monotonic() >= deadline:
                raise AssertionError(f"Timeout waiting for {marker!r}: {self.output[-8000:]!r}")
            if select.select([self.fd], [], [], 0.1)[0]:
                try:
                    data = os.read(self.fd, 65536)
                except OSError as error:
                    if error.errno != errno.EIO:
                        raise
                    data = b""
                if not data:
                    raise AssertionError(f"PTY closed before {marker!r}: {self.output[-8000:]!r}")
                self.output += data
        return self.output[start:]

    def drain(self, seconds=0.3):
        deadline = time.monotonic() + seconds
        while time.monotonic() < deadline:
            if select.select([self.fd], [], [], 0.02)[0]:
                try:
                    data = os.read(self.fd, 65536)
                except OSError as error:
                    if error.errno != errno.EIO:
                        raise
                    break
                if not data:
                    break
                self.output += data

    def close(self):
        # pty.fork creates a new session: this group contains only our fixture.
        try:
            os.killpg(self.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        os.waitpid(self.pid, 0)
        os.close(self.fd)


class ShellSignalTests(unittest.TestCase):
    def command(self, *extra):
        return [str(OPTIONS.factor), "-i=" + str(OPTIONS.image),
                "-resource-path=" + str(ROOT), "-no-user-init", "-no-monitors", *extra]

    def terminal(self, *extra):
        terminal = Terminal(self.command(*extra))
        self.addCleanup(terminal.close)
        return terminal

    def test_nested_shell_interrupts_only_child(self):
        terminal = self.terminal("-run=shell")
        terminal.read_until(b" $ ")
        terminal.send((shlex.join(self.command("-run=shell")) + "\n").encode())
        terminal.read_until(b" $ ")
        source = 'USING: io kernel ; "INNER-READY" print flush [ t ] [ ] while'
        terminal.send((shlex.join(self.command("-e=" + source)) + "\n").encode())
        # The marker also appears in terminal echo, so include its own line.
        terminal.read_until(b"\r\nINNER-READY\r\n")
        start = len(terminal.output)
        terminal.send(b"\x03")
        terminal.read_until(b"Starting low level debugger")
        terminal.drain()
        self.assertEqual(terminal.output[start:].count(b"Interrupted"), 1,
                         terminal.output[start:].decode(errors="replace"))
        terminal.send(b"q\n")
        terminal.read_until(b" $ ")
        # The waiting shell must restore its original handler, including flags.
        start = len(terminal.output)
        terminal.send(b"\x03")
        terminal.read_until(b"Starting low level debugger")
        terminal.drain()
        self.assertEqual(terminal.output[start:].count(b"Interrupted"), 1,
                         terminal.output[start:].decode(errors="replace"))

    def test_plain_command_remains_interruptible(self):
        terminal = self.terminal("-run=shell")
        terminal.read_until(b" $ ")
        terminal.send(b"sleep 30\n")
        terminal.drain()
        start = len(terminal.output)
        terminal.send(b"\x03")
        terminal.read_until(b" $ ")
        self.assertNotIn(b"Starting low level debugger", terminal.output[start:])
        self.assertIn(b"T{ signal { n 2 } }", terminal.output[start:])
        # A nonzero child status throws in try-process; restoration must also
        # happen on that exceptional path.
        terminal.send(b"\x03")
        terminal.read_until(b"Starting low level debugger")

    def test_busy_loop_recovers_at_safepoint(self):
        source = '''USING: continuations io kernel math system ;
            enable-ctrl-break
            [ "LOOP-READY" print flush [ t ] [ ] while ]
            [ drop disable-ctrl-break "LOOP-INTERRUPTED" print ] recover
            40 2 + 42 assert= "RECOVERED" print flush 0 exit'''
        terminal = self.terminal("-e=" + source)
        terminal.read_until(b"LOOP-READY\r\n")
        terminal.send(b"\x03")
        terminal.read_until(b"RECOVERED\r\n")
        self.assertIn(b"LOOP-INTERRUPTED", terminal.output)
        self.assertNotIn(b"Starting low level debugger", terminal.output)

    def test_pipeline_interrupt_preserves_shell(self):
        terminal = self.terminal("-run=shell")
        terminal.read_until(b" $ ")
        terminal.send(b"sleep 30 | cat\n")
        terminal.drain()
        start = len(terminal.output)
        terminal.send(b"\x03")
        terminal.read_until(b" $ ")
        self.assertNotIn(b"Starting low level debugger", terminal.output[start:])
        terminal.send(b"\x03")
        terminal.read_until(b"Starting low level debugger")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--factor", type=Path, default=ROOT / "factor")
    parser.add_argument("--image", type=Path, default=ROOT / "factor.image")
    OPTIONS, rest = parser.parse_known_args()
    unittest.main(argv=[__file__, *rest])
