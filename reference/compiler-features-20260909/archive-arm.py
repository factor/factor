#!/usr/bin/env python3
"""Archive completed observations without modifying original run files."""
import argparse
import gzip
import json
from pathlib import Path
import shutil

HERE = Path(__file__).resolve().parent
SOURCE = HERE.parent / 'compiler-flags-20260909'
p = argparse.ArgumentParser()
p.add_argument('stage', choices=['check', 'timing'])
a = p.parse_args()
out = HERE / 'arm'
out.mkdir(exist_ok=True)
for config in ['00', '10', '11', '01']:
    for ordinal in ([1] if a.stage == 'check' else [1, 2]):
        stem = f'arm-{config}-{a.stage}-linear-scan-{ordinal}'
        status = SOURCE / (stem + '.status.json')
        assert json.loads(status.read_text())['ok'], status
        shutil.copy2(status, out / status.name)
        for suffix in ['.log', '.jsonl']:
            source = SOURCE / (stem + suffix)
            (out / (source.name + '.gz')).write_bytes(gzip.compress(source.read_bytes(), mtime=0))
print('Archived ARM', a.stage)
