"""Source-bound validation, with resumable stages and immutable attempts."""
from contextlib import contextmanager
from datetime import datetime, timezone
import fcntl
import hashlib
import json
from pathlib import Path
import shlex
import subprocess
import uuid

from .config import ROOT, digest
from .guest import Guest
from .process import write_json
from .stages import STAGES, commands, passed
from .transport import Transport


def sha(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def now():
    return datetime.now(timezone.utc).isoformat()


def source_identity(repo=ROOT):
    if subprocess.check_output(['git', 'status', '--porcelain', '--untracked-files=no'], cwd=repo):
        raise ValueError('commit tracked changes before validation; each run needs a reproducible source')
    return {key: subprocess.check_output(['git', 'rev-parse', ref], cwd=repo, text=True).strip()
            for key, ref in [('revision', 'HEAD'), ('tree', 'HEAD^{tree}')]}


@contextmanager
def lock(path):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('a') as stream:
        try:
            fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise ValueError('this profile already has an active runner') from None
        yield


def plan(profile, directory='/tmp/factor-validation'):
    return {'profile': profile['id'], 'transport': profile['transport'],
            'guest': profile.get('guest'), 'seed': profile['seed'],
            'stages': commands(profile, directory), 'elapsed_timeout': None,
            'stall_seconds': profile.get('stall_seconds', 0)}


def attempt(output, name, command, transport, binding, stdin=None):
    number = 1
    while (output / f'{name}-{number}.json').exists():
        number += 1
    path = output / f'{name}-{number}.json'
    log = output / f'{name}-{number}.log'
    receipt = dict(binding=binding, stage=name, command=command, log=log.name,
                   started_at=now(), status='running')
    write_json(path, receipt)
    try:
        code = transport.run(command, log, stdin)
        receipt.update(exit_code=code, status='pass' if passed(name, code, log.read_bytes()) else 'fail')
    except BaseException as error:
        receipt.update(status='interrupted' if isinstance(error, KeyboardInterrupt) else 'fail', error=str(error))
        raise
    finally:
        receipt.update(ended_at=now(), log_sha256=sha(log) if log.exists() else None)
        write_json(path, receipt)
    if receipt['status'] != 'pass':
        raise RuntimeError(f'{name} failed; see {log}')
    return {'receipt': path.name, 'receipt_sha256': sha(path)}


def reusable(output, record, binding):
    path = output / record['receipt']
    if sha(path) != record['receipt_sha256']:
        raise ValueError(f'changed receipt: {path}')
    receipt = json.loads(path.read_text())
    log = output / receipt['log']
    if receipt['binding'] != binding or receipt['status'] != 'pass' or sha(log) != receipt['log_sha256']:
        raise ValueError(f'cannot resume changed evidence: {path}')
    return True


def execute(profile, output, seed, *, resume=False, stages=STAGES, repo=ROOT):
    output = Path(output).resolve()
    seed = Path(seed).resolve(strict=True)
    binding = {'source': source_identity(repo), 'profile_sha256': digest(profile), 'seed_sha256': sha(seed)}
    # One lock across output directories prevents duplicate guests on a profile's ports.
    with lock(Path(profile['assets']) / '.locks' / (profile['id'] + '.lock')):
        if resume:
            state = json.loads((output / 'run.json').read_text())
            if state['binding'] != binding:
                raise ValueError('resume requires the same source, profile, and seed')
            if sha(output / 'source.tar.gz') != state['source_archive_sha256']:
                raise ValueError('source archive changed')
        else:
            output.mkdir(parents=True, exist_ok=False)
            archive = output / 'source.tar.gz'
            with archive.open('xb') as stream:
                subprocess.run(['git', 'archive', '--format=tar.gz', binding['source']['revision']],
                               cwd=repo, stdout=stream, check=True)
            local = profile['transport']['kind'] == 'local'
            directory = str(output / 'source') if local else '/tmp/fc-' + uuid.uuid4().hex[:12]
            state = dict(profile=profile['id'], binding=binding, directory=directory,
                         started_at=now(), status='running', stages={},
                         source_archive_sha256=sha(archive))
        state['status'] = 'running'
        write_json(output / 'run.json', state)
        transport = Transport(profile['transport'], repo, profile.get('stall_seconds', 0))
        guest = Guest(profile.get('guest'), output, transport)
        transport.progress = guest.activity
        try:
            with guest:
                directory = state['directory']
                quote = shlex.quote
                if not state.get('prepared'):
                    with (output / 'source.tar.gz').open('rb') as stream:
                        attempt(output, 'prepare', 'set -eu; mkdir ' + quote(directory) +
                                '; cd ' + quote(directory) + '; tar xzf -', transport, binding, stream)
                    with seed.open('rb') as stream:
                        attempt(output, 'seed', 'cat > ' + quote(directory + '/boot.image'), transport, binding, stream)
                    state['prepared'] = True
                    write_json(output / 'run.json', state)
                for name, command in commands(profile, directory).items():
                    if name not in stages:
                        continue
                    if name in state['stages'] and reusable(output, state['stages'][name], binding):
                        continue
                    state['stages'][name] = attempt(output, name, command, transport, binding)
                    write_json(output / 'run.json', state)
            complete = all(name in state['stages'] for name in STAGES)
            closed = guest.closed is None or (not guest.closed['forced'] and not guest.closed['error']
                       and guest.closed['shutdown_exit'] in (0, 255)
                       and guest.closed['emulator_exit'] == profile.get('guest', {}).get('success_exit', 0))
            state['status'] = 'pass' if complete and closed else 'partial' if closed else 'fail'
        except BaseException as error:
            state.update(status='interrupted' if isinstance(error, KeyboardInterrupt) else 'fail', error=str(error))
            raise
        finally:
            state.update(ended_at=now(), closure=guest.closed)
            write_json(output / 'run.json', state)
    return state
