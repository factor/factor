"""Fresh guest disks and lifecycle, shared by every system-emulation profile."""
from contextlib import AbstractContextManager
import json
from pathlib import Path
import socket
import subprocess
import sys
import time

from . import process
from .transport import Transport, vnc_actions


class Guest(AbstractContextManager):
    def __init__(self, config, directory, transport):
        self.config = config
        self.directory = Path(directory)
        self.transport = transport
        self.child = None
        self.log = None
        self.forced = False
        self.closed = None
        self.outer = None
        self.ready = False

    def activity(self):
        return (process.activity(self.child.pid) if self.child else None,
                self.outer.activity() if self.outer else None)

    def __enter__(self):
        if not self.config:
            return self
        try:
            if 'outer' in self.config:
                outer = self.config['outer']
                outer_directory = self.directory / 'outer'
                outer_directory.mkdir(exist_ok=True)
                outer_transport = Transport(outer['transport'], self.transport.cwd, self.transport.stall_seconds)
                self.outer = Guest(outer['guest'], outer_directory, outer_transport)
                outer_transport.progress = self.outer.activity
                self.outer.__enter__()
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
            for index, drive in enumerate(self.config.get('scratch_drives', [])):
                disk = self.directory / f'scratch-{index}.qcow2'
                if not disk.exists():
                    subprocess.run(['qemu-img', 'create', '-q', '-f', 'qcow2', str(disk), drive['size']], check=True)
                argv += ['-drive', f'file={disk},format=qcow2,' + drive['options']]
            if self.config.get('kind', 'qemu') == 'qemu':
                if self.config.get('qmp', True):
                    self.qmp_path = self.directory / 'qmp.sock'
                    argv += ['-qmp', f'unix:{self.qmp_path},server=on,wait=off']
                if self.transport.config['kind'] == 'serial' and 'socket' in self.transport.config:
                    argv += ['-serial', 'unix:' + self.transport.config['socket'] + ',server=on,wait=off']
                elif self.config.get('console_steps'):
                    self.console_path = self.directory / 'console.sock'
                    argv += ['-chardev', f'socket,id=console,path={self.console_path},server=on,wait=off,logfile={self.directory / "console.log"}',
                             '-serial', 'chardev:console']
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
            self.boot_console()
            self.wait_ready()
            self.ready = True
            setup_record = self.directory / 'setup.json'
            command = self.config.get('setup')
            if setup_record.exists():
                command = self.config.get('resume_setup', command)
            if self.config.get('set_clock'):
                command = f'date -s @{int(time.time())}; ' + (command or 'true')
            if command:
                code = self.transport.run('set -eu; ' + command, self.directory / 'setup.log')
                if code:
                    raise RuntimeError(f'guest setup failed: {code}')
                process.write_json(setup_record, {'command': command, 'exit_code': code})
            return self
        except BaseException:
            self.__exit__(*sys.exc_info())
            raise

    def boot_console(self):
        cursor = 0
        previous = None
        last_progress = time.monotonic()
        for step in self.config.get('console_steps', []):
            while True:
                if self.child.poll() is not None:
                    raise RuntimeError('emulator exited during console setup')
                path = self.directory / 'console.log'
                raw = path.read_bytes() if path.exists() else b''
                found = raw.find(step['expect'].encode(), cursor)
                if found >= 0:
                    cursor = found + len(step['expect'].encode())
                    break
                sample = (len(raw), self.activity())
                if sample != previous:
                    previous = sample
                    last_progress = time.monotonic()
                elif self.transport.stall_seconds and time.monotonic() - last_progress >= self.transport.stall_seconds:
                    raise RuntimeError('boot console stopped making progress')
                time.sleep(.1)
            if step['send']:
                with socket.socket(socket.AF_UNIX) as connection:
                    connection.connect(str(self.console_path))
                    for character in step['send']:
                        connection.sendall(character.encode())
                        time.sleep(self.config.get('console_char_delay', 0))

    def wait_ready(self):
        previous = None
        last_progress = time.monotonic()
        logged_in = not self.transport.config.get('login')
        while True:
            if self.child.poll() is not None:
                raise RuntimeError(f'emulator exited before readiness: {self.child.returncode}')
            try:
                if not logged_in:
                    self.transport.login(self.transport.config['login'], self.directory / 'login.log')
                    logged_in = True
                ready = self.transport.run(self.config.get('ready_command', 'true'),
                                           self.directory / 'readiness.log')
            except (ConnectionError, FileNotFoundError):
                ready = 255
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
        if self.closed is not None:
            return
        if self.child is None:
            if self.log:
                self.log.close()
            if self.outer:
                self.outer.__exit__(*exception)
            return
        shutdown_exit = None
        error = None
        try:
            if self.child.poll() is None:
                if not self.ready:
                    raise RuntimeError('guest failed before readiness; cleaning up the owned emulator')
                try:
                    shutdown_exit = self.transport.run(self.config.get('shutdown', 'sync; poweroff'),
                                                       self.directory / 'shutdown.log')
                except RuntimeError:
                    marker = self.config.get('halt_marker')
                    raw = (self.directory / 'shutdown.log').read_bytes()
                    if not marker or marker.encode() not in raw:
                        raise
                    shutdown_exit = 0
                if shutdown_exit not in (0, 255):
                    raise RuntimeError(f'native shutdown command failed: {shutdown_exit}')
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
            self.forced = process.stop(self.child) or self.forced
            self.log.close()
            if self.outer:
                try:
                    self.outer.__exit__(*exception)
                except BaseException as failure:
                    error = str(failure)
            self.closed = {'emulator_exit': self.child.returncode,
                           'shutdown_exit': shutdown_exit, 'forced': self.forced, 'error': error,
                           'outer': self.outer.closed if self.outer else None}
            process.write_json(self.directory / 'closure.json', self.closed)
        if error and not exception[0]:
            raise RuntimeError(error)
