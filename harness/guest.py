"""Fresh guest disks and lifecycle, shared by every system-emulation profile."""
from contextlib import AbstractContextManager
import json
from pathlib import Path
import socket
import subprocess
import time

from . import process
from .transport import vnc_actions


class Guest(AbstractContextManager):
    def __init__(self, config, directory, transport):
        self.config = config
        self.directory = Path(directory)
        self.transport = transport
        self.child = None
        self.log = None
        self.forced = False
        self.closed = None

    def activity(self):
        return process.activity(self.child.pid) if self.child else None

    def __enter__(self):
        if not self.config:
            return self
        try:
            prior_path = self.directory / 'guest-command.json'
            if prior_path.exists():
                prior = json.loads(prior_path.read_text())
                proc = Path('/proc') / str(prior.get('pid', 0)) / 'stat'
                if proc.exists() and proc.read_text().rsplit(')', 1)[1].split()[19] == prior.get('birth'):
                    raise RuntimeError('previous guest is still running; refusing a duplicate launch')
            argv = list(self.config['argv'])
            for index, drive in enumerate(self.config.get('drives', [])):
                backing = Path(drive['file']).resolve(strict=True)
                overlay = self.directory / f'disk-{index}.qcow2'
                if not overlay.exists():
                    subprocess.run(['qemu-img', 'create', '-q', '-f', 'qcow2', '-F',
                                    drive['format'], '-b', str(backing), str(overlay)], check=True)
                argv += ['-drive', f'file={overlay},format=qcow2,' + drive['options']]
            if self.config.get('qmp', True):
                self.qmp_path = self.directory / 'qmp.sock'
                argv += ['-qmp', f'unix:{self.qmp_path},server=on,wait=off']
            if self.transport.config['kind'] == 'serial':
                argv += ['-serial', 'unix:' + self.transport.config['socket'] + ',server=on,wait=off']
            else:
                argv += ['-serial', 'file:' + str(self.directory / 'console.log')]
            argv += self.config.get('display_args', ['-display', 'none'])
            self.log = (self.directory / 'emulator.log').open('ab')
            self.child = subprocess.Popen(argv, stdout=self.log, stderr=subprocess.STDOUT,
                                          start_new_session=True)
            birth = (Path('/proc') / str(self.child.pid) / 'stat').read_text().rsplit(')', 1)[1].split()[19]
            process.write_json(self.directory / 'guest-command.json',
                               {'argv': argv, 'pid': self.child.pid, 'birth': birth})
            if self.config.get('vnc_actions'):
                vnc_actions(self.config['vnc_server'], self.config['vnc_actions'])
            self.wait_ready()
            return self
        except BaseException:
            self.__exit__(None, None, None)
            raise

    def wait_ready(self):
        previous = None
        last_progress = time.monotonic()
        while True:
            if self.child.poll() is not None:
                raise RuntimeError(f'emulator exited before readiness: {self.child.returncode}')
            ready = self.transport.run(self.config.get('ready_command', 'true'),
                                       self.directory / 'readiness.log')
            if ready == 0:
                return
            console = self.directory / 'console.log'
            sample = (self.activity(), console.stat().st_size if console.exists() else 0)
            if sample != previous:
                previous = sample
                last_progress = time.monotonic()
            elif self.transport.stall_seconds and time.monotonic() - last_progress >= self.transport.stall_seconds:
                raise RuntimeError('guest boot stopped making progress')
            time.sleep(2)

    def qmp(self, command):
        with socket.socket(socket.AF_UNIX) as connection:
            connection.settimeout(10)
            connection.connect(str(self.qmp_path))
            stream = connection.makefile('rwb')
            json.loads(stream.readline())
            for request in ('qmp_capabilities', command):
                stream.write(json.dumps({'execute': request}).encode() + b'\n')
                stream.flush()
                while True:
                    reply = json.loads(stream.readline())
                    if 'error' in reply:
                        raise RuntimeError(reply['error'])
                    if 'return' in reply:
                        break
            return reply['return']

    def __exit__(self, *exception):
        if self.child is None:
            if self.log:
                self.log.close()
            return
        shutdown_exit = None
        error = None
        try:
            if self.child.poll() is None:
                shutdown_exit = self.transport.run(self.config.get('shutdown', 'sync; poweroff'),
                                                   self.directory / 'shutdown.log')
                # SSH commonly disconnects during poweroff. The owned emulator
                # exit, rather than the SSH result alone, establishes closure.
                previous = None
                last_progress = time.monotonic()
                while self.child.poll() is None:
                    sample = self.activity()
                    if sample != previous:
                        previous = sample
                        last_progress = time.monotonic()
                    elif self.transport.stall_seconds and time.monotonic() - last_progress >= self.transport.stall_seconds:
                        raise RuntimeError('guest shutdown stopped making progress')
                    marker = self.config.get('halt_marker')
                    if marker and marker.encode() in (self.directory / 'console.log').read_bytes():
                        self.qmp('quit')
                    time.sleep(1)
        except BaseException as failure:
            error = str(failure)
        finally:
            self.forced = self.child.poll() is None
            process.stop(self.child)
            self.log.close()
            self.closed = {'emulator_exit': self.child.returncode,
                           'shutdown_exit': shutdown_exit, 'forced': self.forced, 'error': error}
            process.write_json(self.directory / 'closure.json', self.closed)
        if error and not exception[0]:
            raise RuntimeError(error)
