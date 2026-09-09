#!/usr/bin/env python3
"""Validate the factorial records and retain per-case and per-round ratios."""
import argparse
import gzip
import json
import math
from pathlib import Path
import statistics

p = argparse.ArgumentParser()
p.add_argument('directory', type=Path)
p.add_argument('--prefix', default='arm')
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
configs = ['00', '10', '01', '11']
metrics = ['instructions', 'cpu_seconds', 'ns']
runs = {}
scope_words = None
outputs = {}
provenance = None

def read_text(path):
    if path.exists():
        return path.read_text()
    with gzip.open(str(path) + '.gz', 'rt') as stream:
        return stream.read()

def read(config, mode, ordinal):
    global scope_words, provenance
    stem = a.directory / f'{a.prefix}-{config}-{mode}-linear-scan-{ordinal}'
    status = json.loads(stem.with_suffix('.status.json').read_text())
    assert status['ok'] and status['exit_code'] == 0, stem
    identity = tuple(status[key] for key in ['source_commit', 'image_sha256', 'vm_sha256']) + (
        status['script_sha256']['timing.factor'], status['script_sha256']['drive.py'])
    if provenance is None:
        provenance = identity
    assert identity == provenance, ('different source/image/VM/harness', stem)
    rows = [json.loads(line) for line in read_text(stem.with_suffix('.jsonl')).splitlines()]
    scope, = [r for r in rows if r['kind'] == 'scope']
    assert scope['options'] == dict(gvn=config[0] == '1', rematerialize_constants=config[1] == '1', backtracking_loop_spills=False)
    assert scope['checked'] == (mode == 'check')
    if scope_words is None:
        scope_words = scope['words']
    assert scope['words'] == scope_words, ('different scope', stem)
    runtime = [r for r in rows if r['kind'] == 'runtime']
    for r in runtime:
        key = r['word']
        if key not in outputs:
            outputs[key] = r['output']
        assert r['output'] == outputs[key], ('different language output', stem, key)
        assert r['instructions'] > 0 and r['cpu_seconds'] > 0
    compile_row, = [r for r in rows if r['kind'] == 'compile']
    per_word = {}
    if mode == 'timing':
        for word in outputs:
            samples = [r for r in runtime if r['word'] == word and r['trial'] >= 0]
            assert sorted(r['trial'] for r in samples) == [0, 1, 2], (stem, word)
            per_word[word] = {m: statistics.median(r[m] for r in samples) for m in metrics}
    return dict(status=status, compile=compile_row, runtime=per_word,
                code={r['report']['input']: r['report'] for r in rows if r['kind'] == 'code'})

for config in configs:
    read(config, 'check', 1)
    runs[config] = [read(config, 'timing', ordinal) for ordinal in [1, 2]]
assert len(outputs) == 26

def geomean(xs):
    return math.exp(statistics.mean(math.log(x) for x in xs))

def comparison(candidate, baseline):
    rounds = []
    for c, b in zip(runs[candidate], runs[baseline]):
        per_case = {w: {m: c['runtime'][w][m] / b['runtime'][w][m] for m in metrics} for w in outputs}
        rounds.append(dict(compile={m: c['compile'][m] / b['compile'][m] for m in metrics},
                           runtime_geomean={m: geomean(v[m] for v in per_case.values()) for m in metrics},
                           per_case=per_case))
    return dict(rounds=rounds,
                compile={m: statistics.mean(r['compile'][m] for r in rounds) for m in metrics},
                compile_geomean={m: geomean(r['compile'][m] for r in rounds) for m in metrics},
                runtime_geomean={m: geomean(r['runtime_geomean'][m] for r in rounds) for m in metrics},
                per_case={w: {m: geomean(r['per_case'][w][m] for r in rounds) for m in metrics} for w in outputs})

interaction_rounds = []
for ordinal in range(2):
    r = {c: runs[c][ordinal] for c in configs}
    per_case = {w: {m: r['11']['runtime'][w][m] * r['00']['runtime'][w][m] /
                   (r['10']['runtime'][w][m] * r['01']['runtime'][w][m])
                   for m in metrics} for w in outputs}
    interaction_rounds.append(dict(
        compile={m: r['11']['compile'][m] * r['00']['compile'][m] /
                 (r['10']['compile'][m] * r['01']['compile'][m]) for m in metrics},
        runtime_geomean={m: geomean(v[m] for v in per_case.values()) for m in metrics},
        per_case=per_case))

result = dict(scope_size=len(scope_words), outputs_match=True, cases=len(outputs),
              measured_batches=624,
              provenance=provenance,
              interaction=dict(formula='M11 * M00 / (M10 * M01)', rounds=interaction_rounds,
                               compile={m: geomean(r['compile'][m] for r in interaction_rounds) for m in metrics},
                               runtime_geomean={m: geomean(r['runtime_geomean'][m] for r in interaction_rounds) for m in metrics}),
              comparisons={f'{c}_vs_{b}': comparison(c, b) for c, b in [('10', '00'), ('01', '00'), ('11', '00'), ('11', '10'), ('11', '01')]},
              observations=runs)
a.output.write_text(json.dumps(result, indent=2) + '\n')
for name, report in result['comparisons'].items():
    print(name, 'compiler', report['compile'], 'runtime', report['runtime_geomean'])
