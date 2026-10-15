"""Source-bound validation, with resumable stages and immutable attempts."""
from contextlib import contextmanager, nullcontext
from datetime import datetime, timezone
import fcntl
import hashlib
import json
import re
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
def lock(path, *, wait=False):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('a') as stream:
        try:
            fcntl.flock(stream, fcntl.LOCK_EX | (0 if wait else fcntl.LOCK_NB))
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
        raw = log.read_bytes()
        receipt.update(exit_code=code, background_cleanup=b'HARNESS_CLEANUP_BACKGROUND_GROUP' in raw,
                       status='pass' if passed(name, code, raw) else 'fail')
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
            run_id = uuid.uuid4().hex
            directory = str(output / 'source') if local else profile.get('work_root', '/tmp').rstrip('/') + '/fc-' + run_id[:12]
            state = dict(profile=profile['id'], binding=binding, directory=directory, run_id=run_id,
                         started_at=now(), status='running', stages={},
                         source_archive_sha256=sha(archive))
        expected_directory = str(output / 'source') if profile['transport']['kind'] == 'local' else profile.get('work_root', '/tmp').rstrip('/') + '/fc-' + state['run_id'][:12]
        if state['directory'] != expected_directory:
            raise ValueError('run directory does not match its recorded identity')
        state.pop('error', None)
        state.pop('ended_at', None)
        state['status'] = 'running'
        write_json(output / 'run.json', state)
        transport = Transport(profile['transport'], repo, profile.get('stall_seconds', 0))
        guest = Guest(profile.get('guest'), output, transport)
        transport.progress = guest.activity
        try:
            with guest:
                directory = state['directory']
                quote = shlex.quote
                setup = state.setdefault('setup', {})
                for name, command, input_path in [
                        ('directory', 'set -eu; if test -d ' + quote(directory) +
                         '; then test "$(cat ' + quote(directory + '/.factor-run') + ')" = ' + quote(state['run_id']) +
                         '; else mkdir ' + quote(directory) + '; printf %s ' + quote(state['run_id']) +
                         ' > ' + quote(directory + '/.factor-run') + '; fi', None),
                        ('source', 'set -eu; cd ' + quote(directory) + '; tar xzf -', output / 'source.tar.gz'),
                        ('seed', 'cat > ' + quote(directory + '/boot.image'), seed)]:
                    if name in setup and reusable(output, setup[name], binding):
                        continue
                    context = input_path.open('rb') if input_path else nullcontext(None)
                    with context as stream:
                        setup[name] = attempt(output, name, command, transport, binding, stream)
                    write_json(output / 'run.json', state)
                if state.get('artifacts'):
                    check_artifacts(profile, directory, output, transport, binding, state)
                for name, command in commands(profile, directory).items():
                    if name not in stages:
                        continue
                    if name in state['stages'] and reusable(output, state['stages'][name], binding):
                        continue
                    shared_io = name in ('io', 'ui')
                    if shared_io:
                        state['waiting_for'] = 'shared IO lock'
                        write_json(output / 'run.json', state)
                    context = lock(Path(profile['assets']) / '.locks' / 'io.lock', wait=True) if shared_io else nullcontext()
                    with context:
                        state.pop('waiting_for', None)
                        write_json(output / 'run.json', state)
                        state['stages'][name] = attempt(output, name, command, transport, binding)
                    if name == 'bootstrap':
                        check_artifacts(profile, directory, output, transport, binding, state)
                    write_json(output / 'run.json', state)
                if state.get('artifacts'):
                    check_artifacts(profile, directory, output, transport, binding, state)
            complete = all(name in state['stages'] for name in STAGES)
            closed = closure_passed(guest.closed, profile.get('guest', {}))
            state['status'] = 'pass' if complete and closed else 'partial' if closed else 'fail'
        except BaseException as error:
            state.update(status='interrupted' if isinstance(error, KeyboardInterrupt) else 'fail', error=str(error))
            raise
        finally:
            state.update(ended_at=now(), closure=guest.closed)
            write_json(output / 'run.json', state)
    return state


def closure_passed(closure, config):
    if closure is None:
        return not config
    return (not closure['forced'] and not closure['error']
            and closure['shutdown_exit'] in (0, 255)
            and closure['emulator_exit'] == config.get('success_exit', 0)
            and closure_passed(closure.get('outer'), config.get('outer', {}).get('guest', {})))


def check_artifacts(profile, directory, output, transport, binding, state):
    names = ['factor', 'factor.image', 'boot.image', 'libfactor-ffi-test.so']
    command = ('set -eu; cd ' + shlex.quote(directory) +
               '; if command -v sha256sum >/dev/null; then sha256sum ' +
               shlex.join(names) + '; else sha256 ' + shlex.join(names) + '; fi')
    record = attempt(output, 'artifacts', command, transport, binding)
    receipt = json.loads((output / record['receipt']).read_text())
    hashes = {}
    for line in (output / receipt['log']).read_text().splitlines():
        match = re.fullmatch(r'([0-9a-f]{64})  ?(.+)', line)
        bsd = re.fullmatch(r'SHA256 \((.+)\) = ([0-9a-f]{64})', line)
        if match:
            hashes[match[2]] = match[1]
        elif bsd:
            hashes[bsd[1]] = bsd[2]
    if set(hashes) != set(names):
        raise ValueError('incomplete runtime artifact hashes')
    if state.get('artifacts', hashes) != hashes:
        raise ValueError('runtime artifacts changed since bootstrap')
    state['artifacts'] = hashes
