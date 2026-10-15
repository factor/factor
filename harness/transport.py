"""The same shell commands run locally, over SSH, or on an owned serial socket."""
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
        argv = (self.config['argv'] + ['sh -c ' + shlex.quote(command)]
                if kind == 'ssh' else ['sh', '-c', command])
        return process.run(argv, log, cwd=self.cwd, stdin=stdin,
                           stall_seconds=self.stall_seconds, progress=self.progress)

    def serial(self, command, log, stdin):
        # A connected console must already be at a shell prompt. Login/bootstrap
        # is a guest setup concern, never guessed by parsing arbitrary boot text.
        token = uuid.uuid4().hex
        marker = ('\nFACTOR_EXIT_' + token + ' ').encode()
        connection = (socket.create_connection((self.config['host'], self.config['port']))
                      if 'host' in self.config else socket.socket(socket.AF_UNIX))
        with connection, Path(log).open('ab') as output:
            if 'socket' in self.config:
                connection.connect(self.config['socket'])
            connection.settimeout(1)
            if stdin is not None:
                # Spool through a private guest file; fixed-size lines fit old UARTs.
                temporary = '/tmp/factor-input-' + token
                connection.sendall(('stty -echo; cat > ' + temporary + ".b64 <<'FACTOR_EOF'\n").encode())
                while chunk := stdin.read(384):
                    connection.sendall(base64.b64encode(chunk) + b'\n')
                connection.sendall(b'FACTOR_EOF\n')
                command = (f'base64 -d {temporary}.b64 > {temporary}; ' +
                           f'sh -c {shlex.quote(command)} < {temporary}; ' +
                           f'code=$?; rm -f {temporary} {temporary}.b64; exit "$code"')
            wrapped = 'sh -c ' + shlex.quote(command)
            connection.sendall((f'{wrapped}; printf "\\nFACTOR_EXIT_{token} %s\\n" "$?"\n').encode())
            buffer = b''
            previous = None
            last_progress = time.monotonic()
            while True:
                try:
                    data = connection.recv(65536)
                    if not data:
                        raise RuntimeError('serial console disconnected before exit status')
                    output.write(data)
                    output.flush()
                    buffer = (buffer + data)[-65536:]
                    last_progress = time.monotonic()
                    if marker in buffer:
                        suffix = buffer.split(marker, 1)[1]
                        if b'\n' in suffix:
                            return int(suffix.splitlines()[0].strip())
                except socket.timeout:
                    sample = self.progress() if self.progress else None
                    if sample != previous:
                        previous = sample
                        last_progress = time.monotonic()
                    elif self.stall_seconds and time.monotonic() - last_progress >= self.stall_seconds:
                        raise RuntimeError('serial console stopped making progress')


def vnc_actions(server, actions):
    """Optional first-boot input, separate from readiness and test execution."""
    from vncdotool import api
    with api.connect(server) as client:
        client.factory.force_caps = True
        for action in actions:
            if 'key' in action:
                client.keyPress(action['key'])
            elif 'text' in action:
                for character in action['text']:
                    client.keyPress('enter' if character == '\n' else character)
            else:
                raise ValueError('VNC action needs key or text')
