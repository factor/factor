#!/usr/bin/env python3
"""Validate the factorial records and retain per-case and per-round ratios."""
import argparse
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

def read(config, mode, ordinal):
    global scope_words
    stem = a.directory / f'{a.prefix}-{config}-{mode}-linear-scan-{ordinal}'
    status = json.loads(stem.with_suffix('.status.json').read_text())
    assert status['ok'] and status['exit_code'] == 0, stem
    rows = [json.loads(line) for line in stem.with_suffix('.jsonl').read_text().splitlines()]
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
                runtime_geomean={m: geomean(r['runtime_geomean'][m] for r in rounds) for m in metrics},
                per_case={w: {m: geomean(r['per_case'][w][m] for r in rounds) for m in metrics} for w in outputs})

result = dict(scope_size=len(scope_words), outputs_match=True, cases=len(outputs),
              measured_batches=624,
              comparisons={f'{c}_vs_{b}': comparison(c, b) for c, b in [('10', '00'), ('01', '00'), ('11', '00'), ('11', '10'), ('11', '01')]},
              observations=runs)
a.output.write_text(json.dumps(result, indent=2) + '\n')
for name, report in result['comparisons'].items():
    print(name, 'compiler', report['compile'], 'runtime', report['runtime_geomean'])
