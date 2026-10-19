#!/usr/bin/env python3
"""Read-only six-hour resource sampling for the owned portability pool."""
import argparse
import datetime
import json
import os
from pathlib import Path
import shutil
import subprocess
import time

BASE = Path('/home/sheeple/factor/work/qemu-matrix/host-resources')

def sample():
    cg = Path('/sys/fs/cgroup') / subprocess.check_output(
        ['systemctl', '--user', 'show', 'factor-ports.slice', '-p', 'ControlGroup', '--value'],
        text=True).strip().lstrip('/')
    locks = json.loads(subprocess.check_output(['lslocks', '--json', '-o', 'PID,PATH'], text=True))
    owners = {}
    for lock in locks.get('locks', []):
        if str(lock.get('path', '')).startswith(str(BASE / 'build-slot-')):
            pid = lock['pid']
            try:
                unit = Path(f'/proc/{pid}/cgroup').read_text().strip().rsplit('/', 1)[-1]
            except OSError:
                unit = 'exited'
            owners[lock['path']] = {'pid': pid, 'unit': unit}
    builds = []
    for directory in BASE.glob('factor-port-*'):
        try:
            record = json.loads((directory / 'command.json').read_text())
            if record['profile'] != 'build' or (directory / 'status.json').exists():
                continue
            unit = record['unit']
            cgunit = cg / unit
            if not cgunit.exists():
                continue
            builds.append({'unit': unit, 'holding_slot': any(x['unit'] == unit for x in owners.values()),
                           'memory_high_bytes': int((cgunit / 'memory.high').read_text()),
            'memory_max_bytes': int((cgunit / 'memory.max').read_text()),
            'memory_bytes': int((cgunit / 'memory.current').read_text())})
        except (OSError, ValueError, KeyError):
            continue
    stat = dict((k, int(v)) for k, v in
                (line.split() for line in (cg / 'memory.stat').read_text().splitlines()))
    oom_units = []
    for path in BASE.glob('factor-port-*/status.json'):
        try:
            status = json.loads(path.read_text())
            if status.get('Result') == 'oom-kill':
                record = json.loads((path.parent / 'command.json').read_text())
                oom_units.append({'unit': record['unit'], 'profile': record['profile'],
                                  'Result': status['Result'],
                                  'MemoryMax': record.get('MemoryMax'),
                                  'memory.events.local': status.get('memory.events.local')})
        except (OSError, ValueError, KeyError):
            continue
    return {'oom_units': oom_units, 'memory_stat': {k: stat.get(k, 0) for k in
                           ('anon', 'file', 'inactive_file', 'kernel', 'shmem')},
            'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'memory_high_bytes': int((cg / 'memory.high').read_text()),
            'memory_max_bytes': int((cg / 'memory.max').read_text()),
            'memory_bytes': int((cg / 'memory.current').read_text()),
            'memory_events': dict((k, int(v)) for k, v in
                                  (line.split() for line in (cg / 'memory.events').read_text().splitlines())),
            'memory_events_local': dict((k, int(v)) for k, v in
                (line.split() for line in (cg / 'memory.events.local').read_text().splitlines())),
            'disk_free_bytes': shutil.disk_usage(BASE).free, 'load': os.getloadavg(),
            'build_slots': owners, 'build_jobs': builds}

def oom_alert(data, baseline):
    # Local oom counts identify the pool limit; hierarchical kills include bounded children.
    if any(data['memory_events_local'].get(k, 0) > baseline['memory_events_local'].get(k, 0)
           for k in ('oom', 'oom_kill', 'oom_group_kill')):
        return 'POOL_LIMIT_OOM_REVIEW'
    if data['memory_events'].get('oom_kill', 0) > baseline['memory_events'].get('oom_kill', 0):
        return 'DESCENDANT_OOM_REVIEW'
    return None

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--hours', type=float, default=6)
    parser.add_argument('--interval', type=float, default=60)
    args = parser.parse_args()
    start = time.monotonic()
    baseline = sample()
    seen = {str(p) for p in BASE.glob('factor-port-*/status.json')}
    while True:
        data = sample()
        alerts = []
        if data['memory_bytes'] > 50 * 1024**3:
            alerts.append('POOL_ABOVE_50_GIB_CHECK_RECLAIMABLE_CACHE')
        if data['memory_stat']['anon'] > 48 * 1024**3:
            alerts.append('ANON_ABOVE_48_GIB_REVIEW_BUILD_HEADROOM')
        event_alert = oom_alert(data, baseline)
        if event_alert:
            alerts.append(event_alert)
        for path in BASE.glob('factor-port-*/status.json'):
            if str(path) in seen:
                continue
            seen.add(str(path))
            try:
                result = json.loads(path.read_text())
                record = json.loads((path.parent / 'command.json').read_text())
                if result.get('Result') == 'oom-kill':
                    alerts.append('NEW_UNIT_OOM:' + record['unit'])
                elif record['profile'] == 'build' and result.get('Result') != 'success':
                    alerts.append('NEW_BUILD_FAILURE:' + record['unit'])
            except (OSError, ValueError, KeyError):
                seen.discard(str(path))
        data['alerts'] = alerts
        encoded = json.dumps(data, separators=(',', ':')) + '\n'
        tmp = BASE / 'monitor-latest.tmp'
        tmp.write_text(encoded)
        tmp.replace(BASE / 'monitor-latest.json')
        with (BASE / 'monitor-history.jsonl').open('a') as history:
            history.write(encoded)
        if alerts:
            with (BASE / 'monitor-alerts.jsonl').open('a') as history:
                history.write(encoded)
            print(encoded, flush=True)
        if time.monotonic() - start >= args.hours * 3600:
            break
        time.sleep(max(0, min(args.interval, args.hours * 3600 - (time.monotonic() - start))))

if __name__ == '__main__':
    main()
