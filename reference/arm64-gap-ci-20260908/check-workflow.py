import yaml
w = yaml.safe_load(open('.github/workflows/build.yml'))
for name in ('build-linux-arm', 'build-macos-arm', 'build-windows-arm'):
    steps = {s.get('name'): s for s in w['jobs'][name]['steps']}
    for suite in ('arm64-regressions', 'arm64-regressions-portable'):
        step = steps[suite]
        assert '.github/arm64-tests.factor' in step['run']
        assert ('-disable-neon-extensions' in step['run']) == suite.endswith('portable')
        assert not step.get('continue-on-error', False)
        if name == 'build-windows-arm':
            assert step['shell'] == 'cmd' and step['run'].startswith('factor.com ')
print('Three ARM64 jobs invoke normal and disabled-extension suites with strict command exits.')
