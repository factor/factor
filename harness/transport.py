"""The same shell commands run locally, over SSH/ADB, or on a serial socket."""
import base64
from pathlib import Path
import shlex
import socket
import time
import uuid

from . import process


class Transport:
    def __init__(self, config, cwd, stall_seconds=0, progress=None):
        self.config = config
        self.cwd = cwd
        self.stall_seconds = stall_seconds
        self.progress = progress

    def run(self, command, log, stdin=None):
        kind = self.config['kind']
        if kind == 'serial':
            return self.serial(command, log, stdin)
        if kind in ('ssh', 'adb'):
            # ADB shell v2 carries the remote exit status. Avoid a PTY so
            # source archives and seed images retain their exact bytes.
            prefix = ['shell', '-T'] if kind == 'adb' else []
            argv = self.config['argv'] + prefix + ['sh -c ' + shlex.quote(command)]
        else:
            argv = ['sh', '-c', command]
        return process.run(argv, log, cwd=self.cwd, stdin=stdin,
                           stall_seconds=self.stall_seconds, progress=self.progress)

    def connect(self):
        if 'host' in self.config:
            return socket.create_connection((self.config['host'], self.config['port']), timeout=1)
        connection = socket.socket(socket.AF_UNIX)
        connection.connect(self.config['socket'])
        return connection

    def send(self, connection, data):
        # sendall() loses the partial count on timeout. Retain the offset so
        # slow UARTs can apply backpressure without corrupting an upload.
        connection.settimeout(1)
        pending = memoryview(data)
        previous = None
        last_progress = time.monotonic()
        while pending:
            try:
                count = connection.send(pending)
                if not count:
                    raise RuntimeError('serial console disconnected during upload')
                pending = pending[count:]
                last_progress = time.monotonic()
            except socket.timeout:
                sample = self.progress() if self.progress else None
                if sample != previous:
                    previous = sample
                    last_progress = time.monotonic()
                elif self.stall_seconds and time.monotonic() - last_progress >= self.stall_seconds:
                    raise RuntimeError('serial upload stopped making progress')

    def receive_until(self, connection, marker, output):
        connection.settimeout(1)
        buffer = b''
        previous = None
        last_progress = time.monotonic()
        while True:
            try:
                data = connection.recv(65536)
                if not data:
                    raise RuntimeError('serial console disconnected before the expected marker')
                output.write(data)
                output.flush()
                buffer = (buffer + data)[-65536:]
                last_progress = time.monotonic()
                if marker in buffer:
                    return buffer
            except socket.timeout:
                sample = self.progress() if self.progress else None
                if sample != previous:
                    previous = sample
                    last_progress = time.monotonic()
                elif self.stall_seconds and time.monotonic() - last_progress >= self.stall_seconds:
                    raise RuntimeError('serial console stopped making progress')

    def receive_to_eof(self, connection, output):
        connection.settimeout(1)
        previous = None
        last_progress = time.monotonic()
        while True:
            try:
                data = connection.recv(65536)
                if not data:
                    return
                output.write(data)
                output.flush()
                last_progress = time.monotonic()
            except socket.timeout:
                sample = self.progress() if self.progress else None
                if sample != previous:
                    previous = sample
                    last_progress = time.monotonic()
                elif self.stall_seconds and time.monotonic() - last_progress >= self.stall_seconds:
                    raise RuntimeError('serial upload stopped making progress')

    def login(self, steps, log):
        with self.connect() as connection, Path(log).open('ab') as output:
            for step in steps:
                self.receive_until(connection, step['expect'].encode(), output)
                text = Path(step['send_file']).read_text().strip() if 'send_file' in step else step['send']
                self.send(connection, text.encode() + b'\n')

    def serial(self, command, log, stdin):
        token = uuid.uuid4().hex
        marker = ('\nFACTOR_EXIT_' + token + ' ').encode()
        temporary = '/tmp/factor-input-' + token
        if stdin is not None and self.config.get('binary_stdin'):
            # The owned TCP shell is binary clean. End its input half after a
            # raw transfer, then run the command through a fresh connection.
            with self.connect() as connection, Path(log).open('ab') as output:
                ready = ('FACTOR_UPLOAD_' + token + '\n').encode()
                self.send(connection, ("printf '" + ready.decode() + "'; exec cat > " +
                                       shlex.quote(temporary) + '\n').encode())
                self.receive_until(connection, ready, output)
                while chunk := stdin.read(65536):
                    self.send(connection, chunk)
                connection.shutdown(socket.SHUT_WR)
                self.receive_to_eof(connection, output)
            command = (f'sh -c {shlex.quote(command)} < {temporary}; ' +
                       f'code=$?; rm -f {temporary}; exit "$code"')
            stdin = None
        with self.connect() as connection, Path(log).open('ab') as output:
            if stdin is not None:
                # Fixed-size base64 lines fit old UARTs; the guest spool is private.
                self.send(connection, ('stty -echo; cat > ' + temporary + ".b64 <<'FACTOR_EOF'\n").encode())
                while chunk := stdin.read(384):
                    self.send(connection, base64.b64encode(chunk) + b'\n')
                self.send(connection, b'FACTOR_EOF\n')
                command = (f'base64 -d {temporary}.b64 > {temporary}; ' +
                           f'sh -c {shlex.quote(command)} < {temporary}; ' +
                           f'code=$?; rm -f {temporary} {temporary}.b64; exit "$code"')
            wrapped = 'sh -c ' + shlex.quote(command)
            self.send(connection, (f'stty -echo; {wrapped}; printf "\\nFACTOR_EXIT_{token} %s\\n" "$?"\n').encode())
            suffix = self.receive_until(connection, marker, output).split(marker, 1)[1]
            if b'\n' not in suffix:
                suffix += self.receive_until(connection, b'\n', output)
            return int(suffix.splitlines()[0].strip())


def vnc_actions(server, actions):
    """Optional first-boot input, separate from readiness and test execution."""
    from vncdotool import api
    try:
        with api.connect(server) as client:
            client.factory.force_caps = True
            for action in actions:
                if 'key' in action:
                    client.keyPress(action['key'])
                elif 'text' in action:
                    for character in action['text']:
                        client.keyPress('enter' if character == '\n' else character)
                elif 'move' in action:
                    client.mouseMove(*action['move'])
                elif 'click' in action:
                    client.mousePress(action['click'])
                elif 'pause' in action:
                    time.sleep(action['pause'])
                else:
                    raise ValueError('VNC action needs key, text, move, click, or pause')
    finally:
        api.shutdown()
