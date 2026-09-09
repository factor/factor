#!/usr/bin/env python3
"""Checked factorial gate followed by balanced fresh-process observations."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('stage', choices=['check', 'timing'])
args = parser.parse_args()
manifest = json.loads((HERE / 'arm-source.json').read_text())

def verify_source():
    for name, expected in manifest['files'].items():
        assert hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == expected, name

order = ['00', '10', '11', '01']
if args.stage == 'timing':
    expected_scope = None
    expected_outputs = None
    for config in order:
        status = ROOT / f'reference/compiler-flags-20260909/arm-{config}-check-linear-scan-1.status.json'
        assert json.loads(status.read_text())['ok'], status
        records_path = status.with_name(status.name.replace('.status.json', '.jsonl'))
        records = [json.loads(line) for line in records_path.read_text().splitlines()]
        scope, = [row['words'] for row in records if row['kind'] == 'scope']
        outputs = {row['word']: row['output'] for row in records if row['kind'] == 'runtime'}
        assert len(outputs) == 26
        if expected_scope is None:
            expected_scope, expected_outputs = scope, outputs
        assert scope == expected_scope, ('different scope', config)
        assert outputs == expected_outputs, ('different language outputs', config)
    order += list(reversed(order))
for index, config in enumerate(order):
    verify_source()
    subprocess.run([
        'python3', str(ROOT / 'reference/compiler-flags-20260909/drive.py'),
        'arm-' + config, '--mode', args.stage, '--allocator', 'linear-scan',
        '--gvn', 'on' if config[0] == '1' else 'off',
        '--rematerialize', 'on' if config[1] == '1' else 'off',
        '--loop-spills', 'off', '--samples', '3',
        '--round-offset', str(index // 4),
        '--image', str(HERE / 'prepared.image'),
    ], cwd=ROOT, check=True)
    verify_source()
print('ARM', args.stage, 'COMPLETE', flush=True)
