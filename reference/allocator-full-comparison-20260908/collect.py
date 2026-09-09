#!/usr/bin/env python3
"""Collect exactly the accepted two-round matrix; reject stale copied artifacts."""
import argparse, gzip, io, json, shlex, subprocess, tarfile
from pathlib import Path

ALLOCATORS = ('linear-scan', 'greedy', 'backtracking', 'chordal')
REL = 'reference/allocator-speed-crossarch-20260908'
OPTIONS = {'rematerialize_constants': True, 'backtracking_loop_spills': True, 'gvn': False}
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('baseline'); p.add_argument('candidate'); p.add_argument('output', type=Path)
p.add_argument('--baseline-source', required=True); p.add_argument('--candidate-source', required=True)
p.add_argument('--remote-host')
a = p.parse_args()
collected = {}; provenance = {}; all_outputs = {}
for label in ('baseline', 'candidate'):
    root = getattr(a, label); source = getattr(a, label + '_source')
    runs = [(f'{label}-{mode}-{allocator}-{ordinal}', mode, allocator)
            for mode, ordinals in [('check', (1,)), ('timing', (1, 2))]
            for ordinal in ordinals for allocator in ALLOCATORS]
    if label == 'candidate':
        runs += [(f'remat-off-timing-linear-scan-{ordinal}', 'timing', 'linear-scan')
                 for ordinal in (1, 2)]
    names = [name + suffix for name, _, _ in runs for suffix in ('.jsonl', '.status.json')]
    names += ['source-expected.json', 'source-manifest.json']
    if a.remote_host:
        quote = shlex.quote
        command = ('python3 ' + quote(root + '/' + REL + '/source-manifest.py') +
                   ' >/dev/null && tar -C ' + quote(root) +
                   ' -cf - .allocator-source-commit .allocator-prepared-source-commit -C ' +
                   quote(root + '/' + REL) + ' ' + ' '.join(map(quote, names)))
        raw = subprocess.check_output(['ssh', a.remote_host, command])
        with tarfile.open(fileobj=io.BytesIO(raw)) as archive:
            files = {}
            for member in archive:
                assert member.name in names + ['.allocator-source-commit', '.allocator-prepared-source-commit']
                assert member.isfile(), member.name
                files[member.name] = archive.extractfile(member).read()
    else:
        base = Path(root)
        subprocess.run(['python3', str(base / REL / 'source-manifest.py')], check=True)
        files = {n: (base / REL / n).read_bytes() for n in names}
        for n in ('.allocator-source-commit', '.allocator-prepared-source-commit'):
            files[n] = (base / n).read_bytes()
    for marker in ('.allocator-source-commit', '.allocator-prepared-source-commit'):
        assert files[marker].decode().strip() == source, (label, marker, 'source drift')
    manifest = json.loads(files['source-manifest.json'])
    assert manifest['source_commit'] == source and manifest['all_match']
    scope_words = None; statuses = {}
    for name, mode, allocator in runs:
        status = json.loads(files[name + '.status.json'])
        assert status['ok'] and status['exit_code'] == 0 and status['source_commit'] == source, name
        assert status['final_value_verifier'] == (mode == 'check'), name
        rows = [json.loads(line) for line in files[name + '.jsonl'].splitlines()]
        scopes = [x for x in rows if x['kind'] == 'scope']; assert len(scopes) == 1, name
        scope = scopes[0]
        assert scope['source'] == source and scope['allocator'] == allocator, name
        expected_options = dict(OPTIONS)
        if name.startswith('remat-off-'): expected_options['rematerialize_constants'] = False
        assert scope['checked'] == (mode == 'check') and scope['options'] == expected_options, name
        if scope_words is None: scope_words = scope['words']
        assert scope_words == scope['words'], (name, 'frozen object sequence changed')
        assert sum(x['kind'] == 'compile' for x in rows) == 1, name
        assert sum(x['kind'] == 'code' for x in rows) == 12, name
        runtime = [x for x in rows if x['kind'] == 'runtime']
        assert len(runtime) == (26 if mode == 'check' else 104), name
        words = {x['word'] for x in runtime}; assert len(words) == 26, name
        for word in words:
            samples = [x for x in runtime if x['word'] == word]
            assert sorted(x['trial'] for x in samples) == ([-1] if mode == 'check' else [-1, 0, 1, 2]), name
            for sample in samples:
                assert sample['instructions'] > 0 and sample['cpu_seconds'] > 0, name
                if word in all_outputs: assert sample['output'] == all_outputs[word], (name, word)
                all_outputs[word] = sample['output']
        collected[name + '.jsonl.gz'] = gzip.compress(files[name + '.jsonl'], mtime=0)
        collected[name + '.status.json'] = files[name + '.status.json']
        statuses[name] = status
    provenance[label] = dict(source_commit=source, frozen_words=len(scope_words), root=root, runs=statuses)
    for name in ('source-expected.json', 'source-manifest.json'):
        collected[label + '-' + name] = files[name]
a.output.mkdir(parents=True, exist_ok=True)
assert not list(a.output.glob('*.jsonl*')), 'Use an empty matrix artifact directory'
for name, data in collected.items(): (a.output / name).write_bytes(data)
(a.output / 'collection.json').write_text(json.dumps(dict(accepted=True, remote_host=a.remote_host,
    main_measured_batches=1248, attribution_measured_batches=156, measured_batches=1404,
    checked_batches=208, sources=provenance), indent=2) + '\n')
print('Collected 16 main + 2 attribution + 8 checked runs; 1,404 measured batches and 208 checked outputs')
