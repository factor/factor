"""Owned subprocesses, activity monitoring, and durable result writes."""
import json
import os
from pathlib import Path
import signal
import subprocess
import tempfile
import time


def write_json(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=path.name + '.', dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as stream:
            json.dump(value, stream, indent=2, sort_keys=True)
            stream.write('\n')
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
        directory = os.open(path.parent, os.O_RDONLY | os.O_DIRECTORY)
        try:
            os.fsync(directory)
        finally:
            os.close(directory)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def activity(pid):
    """Include child CPU and IO so a quiet compiler still makes progress."""
    counters = [0, 0]
    pending = [pid]
    seen = set()
    while pending:
        current = pending.pop()
        if current in seen:
            continue
        seen.add(current)
        try:
            proc = Path('/proc') / str(current)
            fields = (proc / 'stat').read_text().rsplit(')', 1)[1].split()
            counters[0] += sum(int(fields[i]) for i in (11, 12, 13, 14))
            counters[1] += sum(int(line.split(':')[1]) for line in (proc / 'io').read_text().splitlines())
            for task in (proc / 'task').iterdir():
                pending.extend(map(int, (task / 'children').read_text().split()))
        except (OSError, ValueError):
            continue
    return tuple(counters)


def stop(process):
    """Reap the owned child and remove descendants in its private process group."""
    running = process.poll() is None
    try:
        os.killpg(process.pid, signal.SIGTERM if running else signal.SIGKILL)
    except ProcessLookupError:
        process.wait()
        return False
    if not running:
        return True  # The command exited while leaving background children.
    try:
        process.wait(timeout=10)
    except subprocess.TimeoutExpired:
        os.killpg(process.pid, signal.SIGKILL)
        process.wait()
    return False


def run(argv, log, *, cwd=None, env=None, stdin=None, stall_seconds=0,
        progress=None, poll_seconds=1):
    with Path(log).open('ab', buffering=0) as output:
        child = subprocess.Popen(argv, cwd=cwd, env=env, stdin=stdin,
                                 stdout=output, stderr=subprocess.STDOUT,
                                 start_new_session=True)
        previous = None
        last_progress = time.monotonic()
        try:
            while child.poll() is None:
                sample = (output.tell(), activity(child.pid), progress() if progress else None)
                if sample != previous:
                    previous = sample
                    last_progress = time.monotonic()
                elif stall_seconds and time.monotonic() - last_progress >= stall_seconds:
                    raise RuntimeError(f'no CPU, IO, or output progress for {stall_seconds}s')
                time.sleep(poll_seconds)
        finally:
            leftovers = stop(child)
        if leftovers:
            output.write(b'\nHARNESS_CLEANUP_BACKGROUND_GROUP\n')
        return child.returncode
