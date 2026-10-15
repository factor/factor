#!/usr/bin/env python3
"""Detached, bounded systemd user services for Factor portability jobs."""
import argparse
import datetime
import errno
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time

BASE = Path('/home/sheeple/factor/work/qemu-matrix/host-resources')
PROFILES = {'vm': ('6G', '8G'), 'controller': ('3G', '4G'),
            'large-controller': ('6G', '8G'), 'guest-controller': ('256M', '512M'),
            'guest-watch': ('96M', '128M'), 'probe': ('768M', '1G'), 'build': ('10G', '12G'),
            'fixture': ('64M', '64M')}


def atomic_write(path, text):
    """Retain the prior receipt if storage runs out during an update."""
    path = Path(path)
    descriptor, temporary = tempfile.mkstemp(prefix=path.name + '.', suffix='.tmp', dir=path.parent)
    try:
        with os.fdopen(descriptor, 'w') as stream:
            stream.write(text)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        try:
            os.unlink(temporary)
        except FileNotFoundError:
            pass


def write_json(path, data):
    atomic_write(path, json.dumps(data, indent=2) + '\n')


def known_waiting(path):
    """A malformed existing admission receipt still reserves its job's growth."""
    try:
        return json.loads(path.read_text()).get('admitted') is False
    except (OSError, ValueError, AttributeError):
        return False


def capture(directory, unit):
    props = subprocess.check_output(['systemctl', '--user', 'show', unit,
        '-p', 'ControlGroup', '-p', 'Result', '-p', 'ExecMainCode',
        '-p', 'ExecMainStatus', '-p', 'MemoryPeak'], text=True)
    data = dict(line.split('=', 1) for line in props.splitlines() if '=' in line)
    data['SERVICE_RESULT'] = os.environ.get('SERVICE_RESULT')
    data['EXIT_CODE'] = os.environ.get('EXIT_CODE')
    data['EXIT_STATUS'] = os.environ.get('EXIT_STATUS')
    cg = Path('/sys/fs/cgroup') / data.get('ControlGroup', '').lstrip('/')
    for name in ('memory.events', 'memory.events.local', 'memory.peak'):
        try:
            data[name] = (cg / name).read_text()
        except OSError as error:
            data[name] = str(error)
    write_json(Path(directory) / 'status.json', data)


def admission_check(directory, record):
    """Called under admission.lock; reserve only new jobs and active heavy host slots."""
    cg = Path('/sys/fs/cgroup') / subprocess.check_output(
        ['systemctl', '--user', 'show', 'factor-ports.slice', '-p', 'ControlGroup', '--value'],
        text=True).strip().lstrip('/')
    stat = dict((k, int(v)) for k, v in
                (line.split() for line in (cg / 'memory.stat').read_text().splitlines()))
    high = int((cg / 'memory.high').read_text())
    ceiling = min(high - 2 * 1024**3, int((cg / 'memory.max').read_text()) - 4 * 1024**3)
    own = cg / record['unit']
    demand = int((own / 'memory.max').read_text())
    reserve = 0
    holders = json.loads(subprocess.check_output(['lslocks', '--json', '-o', 'PID,PATH'], text=True))
    holder_units = set()
    for item in holders.get('locks', []):
        if str(item.get('path', '')).startswith(str(BASE / 'build-slot-')):
            try:
                holder_units.add(Path(f"/proc/{item['pid']}/cgroup").read_text().strip().rsplit('/', 1)[-1])
            except OSError:
                pass
    for other in cg.glob('*.service'):
        if other == own:
            continue
        admitted = BASE / other.name.removesuffix('.service') / 'admission.json'
        if other.name not in holder_units and not admitted.exists():
            continue
        try:
            if admitted.exists() and known_waiting(admitted):
                continue
            events = dict(line.split() for line in (other / 'cgroup.events').read_text().splitlines())
            if events.get('populated') != '1':
                continue
            used = dict((k, int(v)) for k, v in
                        (line.split() for line in (other / 'memory.stat').read_text().splitlines()))['anon']
            reserve += max(0, int((other / 'memory.max').read_text()) - used)
        except (OSError, ValueError, KeyError):
            continue
    info = dict(line.split(':', 1) for line in Path('/proc/meminfo').read_text().splitlines())
    available = int(info['MemAvailable'].split()[0]) * 1024
    own_used = dict((k, int(v)) for k, v in
                    (line.split() for line in (own / 'memory.stat').read_text().splitlines()))['anon']
    projected = stat['anon'] + reserve + max(0, demand - own_used)
    state = {'admitted': projected <= ceiling and available >= 24 * 1024**3,
             'anon_bytes': stat['anon'], 'reserved_growth_bytes': reserve,
             'demand_bytes': demand, 'projected_bytes': projected, 'ceiling_bytes': ceiling,
             'host_available_bytes': available, 'utc': datetime.datetime.now(datetime.timezone.utc).isoformat()}
    write_json(directory / 'admission.json', state)
    return state['admitted']


def acquire_slots(record):
    """Nonblocking; caller holds admission.lock. Never reserve while queued."""
    import fcntl
    locks = []
    for kind, count in [('test', 20)] * bool(record.get('test_cohort')) + [('build', 2)] * (record['profile'] == 'build'):
        for slot in range(count):
            handle = open(BASE / f'{kind}-slot-{slot}.lock', 'a')
            try:
                fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
                locks.append(handle)
                break
            except BlockingIOError:
                handle.close()
        else:
            for handle in locks:
                handle.close()
            return None
    return locks


def run(directory):
    import fcntl
    directory = Path(directory)
    record = json.loads((directory / 'command.json').read_text())
    locks = []
    while record['profile'] != 'fixture':
        admitted = False
        with (BASE / 'admission.lock').open('a') as guard:
            fcntl.flock(guard, fcntl.LOCK_EX)
            try:
                # Persist non-admission before slot acquisition: queued test jobs
                # must not contribute a full reservation to other decisions.
                write_json(directory / 'admission.json', {'admitted': False,
                    'reason': 'waiting-for-slots-and-admission', 'timer_started': False})
                locks = acquire_slots(record)
                if locks is not None:
                    admitted = admission_check(directory, record)
            except OSError as error:
                if error.errno not in (errno.ENOSPC, errno.EDQUOT):
                    raise
            finally:
                if not admitted:
                    for handle in locks or []:
                        handle.close()
                    locks = []
        if admitted:
            break
        time.sleep(5)
    result = subprocess.run(record['argv'], cwd=record['cwd'], env=record['env'])
    atomic_write(directory / 'exitcode', str(result.returncode) + '\n')
    sys.exit(result.returncode if result.returncode >= 0 else 128 - result.returncode)


def main():
    if sys.argv[1:2] == ['_capture']:
        capture(*sys.argv[2:4]); return
    if sys.argv[1:2] == ['_run']:
        run(sys.argv[2]); return
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--profile', choices=PROFILES, required=True)
    parser.add_argument('--name', required=True)
    parser.add_argument('--test-cohort', action='store_true', help='cap full bootstrap/compiler/IO/UI gate controllers at 20; resource admission still applies')
    parser.add_argument('command', nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if args.test_cohort and args.profile == 'fixture':
        parser.error('fixture cannot bypass admission for a test cohort')
    command = args.command[1:] if args.command[:1] == ['--'] else args.command
    if not command or not all(c.isalnum() or c == '-' for c in args.name):
        parser.error('provide a command and an alphanumeric/hyphen name')
    limits = subprocess.check_output(['systemctl', '--user', 'show', 'factor-ports.slice',
        '-p', 'MemoryHigh', '-p', 'MemoryMax', '-p', 'CPUQuotaPerSecUSec'], text=True)
    if not all(value in limits.splitlines() for value in
               ('MemoryHigh=77309411328', 'MemoryMax=90194313216', 'CPUQuotaPerSecUSec=24s')):
        parser.error('install/start misc/qemu/factor-ports.slice first (see HOST-JOBS.md)')
    BASE.mkdir(parents=True, exist_ok=True)
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S')
    unit = f'factor-port-{args.name}-{stamp}-{os.getpid()}.service'
    directory = BASE / unit.removesuffix('.service')
    directory.mkdir(mode=0o700)
    high, maximum = PROFILES[args.profile]
    record = {'argv': command, 'cwd': os.getcwd(), 'env': dict(os.environ),
              'profile': args.profile, 'unit': unit, 'MemoryHigh': high, 'MemoryMax': maximum,
              'test_cohort': args.test_cohort}
    write_json(directory / 'command.json', record)
    helper = str(Path(__file__).resolve())
    launch = ['systemd-run', '--user', '--unit=' + unit, '--slice=factor-ports.slice',
              '--service-type=exec', '--property=MemoryAccounting=yes',
              '--property=MemoryHigh=' + high, '--property=MemoryMax=' + maximum,
              '--property=MemorySwapMax=0', '--property=OOMPolicy=stop',
              '--property=KillMode=control-group', '--property=TimeoutStopSec=30',
              '--property=StandardOutput=append:' + str(directory / 'stdout.log'),
              '--property=StandardError=append:' + str(directory / 'stderr.log'),
              '--property=ExecStopPost=/usr/bin/python3 ' + helper + ' _capture ' + str(directory) + ' ' + unit,
              '/usr/bin/python3', helper, '_run', str(directory)]
    write_json(directory / 'launch.json', launch)
    subprocess.run(launch, check=True)
    print(json.dumps({'unit': unit, 'directory': str(directory)}))

if __name__ == '__main__':
    main()
