#!/usr/bin/env python3
"""Run one owned validation process with foreground policy and saved evidence."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import selectors
import signal
import subprocess
import time

from process_usage import usage, timebase

ROOT = Path(__file__).resolve().parents[2]
ART = Path(__file__).resolve().parent


def digest(path):
    checksum = hashlib.sha256()
    with path.open('rb') as source:
        for block in iter(lambda: source.read(1048576), b''):
            checksum.update(block)
    return checksum.hexdigest()


def run(args):
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    cwd = args.cwd.resolve()
    command = args.command
    if command and command[0] == '--':
        command = command[1:]
    if not command:
        raise SystemExit('A command is required after --')
    git = lambda *a: subprocess.check_output(['git', *a], cwd=cwd, text=True).strip()
    status = dict(command=command, cwd=str(cwd), source=git('rev-parse', 'HEAD'),
                  source_status=git('status', '--short', '--untracked-files=no'),
                  host=platform.uname()._asdict(), mach_timebase=dict(
                      numer=timebase.numer, denom=timebase.denom), assets={})
    for name in ('Factor.app/Contents/MacOS/factor', 'libfactor.dylib', 'factor.image'):
        path = cwd / name
        if path.exists():
            status['assets'][name] = digest(path)
    executable = Path(command[0])
    if not executable.is_absolute():
        executable = cwd / executable
    if executable.is_file():
        status['executable'] = dict(path=str(executable.resolve()), sha256=digest(executable))
    for argument in command[1:]:
        if argument.startswith('-i='):
            image = Path(argument[3:])
            if not image.is_absolute():
                image = cwd / image
            status['input_image'] = dict(path=str(image.resolve()), sha256=digest(image))
    (output / 'environment.json').write_text(json.dumps(status, indent=2) + '\n')
    started = time.monotonic()
    child = subprocess.Popen(command, cwd=cwd, stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT, start_new_session=True)
    selector = selectors.DefaultSelector()
    selector.register(child.stdout, selectors.EVENT_READ)
    samples, phases, latest = [], [], {}
    failures, next_tick, pending, timed_out = 0, started, b'', False

    def sample(kind, text=None):
        nonlocal latest
        measured = usage(child.pid)
        if measured is not None:
            latest = measured
        row = dict(kind=kind, elapsed=time.monotonic() - started,
                   snapshot_valid=measured is not None, load=os.getloadavg(), **latest)
        if text is not None:
            row['text'] = text
            phases.append(row)
        samples.append(row)

    with (output / 'output.log').open('wb') as log:
        while selector.get_map():
            now = time.monotonic()
            if now - started > args.timeout and not timed_out:
                timed_out = True
                os.killpg(child.pid, signal.SIGKILL)
            if now >= next_tick:
                result = subprocess.run(['/usr/sbin/taskpolicy', '-B', '-p', str(child.pid)],
                                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                failures += result.returncode != 0
                sample('sample')
                next_tick = now + 1
            for key, _ in selector.select(timeout=max(0, min(.1, next_tick - time.monotonic()))):
                data = os.read(key.fd, 65536)
                if not data:
                    sample('eof')
                    selector.unregister(key.fileobj)
                    continue
                log.write(data)
                log.flush()
                pending += data
                while b'\n' in pending:
                    line, pending = pending.split(b'\n', 1)
                    text = line.decode(errors='replace')
                    if any(marker in text for marker in (
                            'SPEED ', 'MATRIX ', '* Loading', 'bootstrap completed',
                            'Bootstrapping is complete.', 'TEST-FAILURES')):
                        sample('phase', text)
    child.wait()
    child.stdout.close()
    selector.close()
    status.update(exit_code=child.returncode, seconds=time.monotonic() - started,
                  timed_out=timed_out, foreground_refresh_failures=failures,
                  phase_usage=phases, last_process_usage=latest,
                  counter_note='PID counters exclude taskpolicy helpers; last valid sample may precede exit.')
    (output / 'samples.jsonl').write_text(''.join(json.dumps(row) + '\n' for row in samples))
    (output / 'status.json').write_text(json.dumps(status, indent=2) + '\n')
    print(json.dumps(dict(output=str(output), exit_code=child.returncode,
                          seconds=status['seconds'], timed_out=timed_out)))
    return child.returncode


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cwd', type=Path, default=ROOT)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--timeout', type=int, default=1200)
    parser.add_argument('command', nargs=argparse.REMAINDER)
    raise SystemExit(run(parser.parse_args()))
