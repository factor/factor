import json
import statistics
from pathlib import Path

root = Path(__file__).resolve().parent
allocators = ['linear-scan', 'greedy', 'backtracking', 'chordal']
summary = {'platform': 'macOS ARM64', 'trials': 3,
           'allocation-checks': False, 'global-numbering': False,
           'metric': 'sum of per-word medians across fresh processes',
           'allocators': {}}
for allocator in allocators:
    samples = []
    runtime = {}
    for trial in range(1, 4):
        path = root / f'timing-{allocator}-{trial}.jsonl'
        rows = [json.loads(line) for line in path.read_text().splitlines()]
        compiles = [r for r in rows if r['phase'] == 'compile']
        runs = [r for r in rows if r['phase'] == 'runtime']
        assert len(compiles) == 13 and len(runs) == 10, path
        assert all(r['allocation-checks'] is False for r in compiles), path
        samples.append({r['input']: r for r in compiles})
        for run in runs:
            runtime.setdefault(run['input'], []).append(run)
    assert all(set(s) == set(samples[0]) for s in samples)
    report = {}
    for metric in ['compile-instructions', 'compile-cpu-seconds']:
        report[metric] = sum(statistics.median(s[word][metric] for s in samples)
                             for word in samples[0])
    totals = []
    for sample in samples:
        procedures = [p for r in sample.values() for p in r['procedures']]
        final = [p['passes'][-1] for p in procedures]
        totals.append({'code-bytes': sum(p['code-bytes'] for p in procedures),
                       **{key: sum(p[key] for p in final)
                          for key in ['spills', 'reloads', 'copies']}})
    assert all(s == totals[0] for s in totals), allocator
    report.update(totals[0])
    report['runtime'] = {}
    for word, runs in runtime.items():
        assert all(r['result'] == runs[0]['result'] for r in runs)
        report['runtime'][word] = {'result': runs[0]['result'], 'samples': len(runs),
            **{key: statistics.median(r[key] for r in runs)
               for key in ['instructions', 'cpu-seconds', 'nanoseconds']}}
    summary['allocators'][allocator] = report
baseline = summary['allocators']['linear-scan']
for report in summary['allocators'].values():
    for metric in ['compile-instructions', 'compile-cpu-seconds']:
        report[metric + '-relative'] = report[metric] / baseline[metric]
    assert {w: r['result'] for w, r in report['runtime'].items()} == {
        w: r['result'] for w, r in baseline['runtime'].items()}
(root / 'timing-summary.json').write_text(json.dumps(summary, indent=2) + '\n')
for allocator, report in summary['allocators'].items():
    print(allocator, report['code-bytes'], report['spills'], report['copies'],
          round(report['compile-instructions-relative'], 4),
          round(report['compile-cpu-seconds-relative'], 4))
