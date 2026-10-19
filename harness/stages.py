"""One build and test sequence; profiles supply tools and genuine exceptions."""
import shlex

STAGES = ('build', 'numeric', 'bootstrap', 'reopen', 'core', 'compiler', 'io', 'ui')
BUILD_ARCHIVE = 'build-artifacts.tar.gz'


def shell_env(values):
    return ''.join('export ' + key + '=' + shlex.quote(value) + '; '
                   for key, value in values.items())


def commands(profile, directory, build_directory=None):
    quote = shlex.quote
    build = profile['build']
    execution = profile.get('execution', {})
    runner = execution.get('runner', [])
    make_tool = build.get('make', 'gmake')
    make = [make_tool, 'CONFIG=vm/Config.' + build['config'],
            'BUILD_DIR=build-validation', '-j' + str(build.get('jobs', 1)),
            *build.get('args', [])]
    factor = [*runner, './factor',
              '-no-user-init', '-resource-path=' + directory, *profile.get('heap', [])]
    normal = shlex.join([*factor, '-i=' + directory + '/factor.image'])
    directories = {key: directory + '/' + value for key, value in
                   execution.get('directories', {}).items()}
    run_setup = ''
    if directories:
        run_setup = 'mkdir -p ' + shlex.join(directories.values()) + '; '
    run_setup += shell_env(dict(execution.get('env', {}), **directories,
                                FACTOR_TEST_CHILD_IMAGE=directory + '/factor.image'))
    build_env = shell_env(build.get('env', {}))
    cwd = 'set -eu; cd ' + quote(directory) + '; '
    numeric_make = [make_tool, '-f',
                    'vm/tests/Makefile.ieee-float', 'BUILD_DIR=build-numeric']
    code = {
        'build': shlex.join(make + build.get('targets', ['factor-executable', 'factor-ffi-test'])),
        'numeric': build_env + shlex.join([*numeric_make,
                    'RUNNER=' + shlex.join(runner), 'check']),
        'bootstrap': shlex.join([*factor, '-i=' + directory + '/boot.image',
                                '-output-image=' + directory + '/factor.image']),
        'reopen': normal + ' ' + quote('-e=USING: io ; "FACTOR_REOPEN_OK" print'),
        'core': normal + ' misc/qemu/core-gate.factor',
        'compiler': normal + ' -run=tools.test compiler',
        'io': shlex.join(profile.get('io_prefix', [])) + ' ' + normal + ' -run=tools.test io',
        'ui': normal + ' -run=tools.test ui',
    }
    code.update(profile.get('commands', {}))
    if build.get('host'):
        # Cross builds run on the host; their binaries and numeric probes travel
        # together to the guest, where all remaining stages execute.
        build_directory = build_directory or directory + '-build'
        code['build'] += ('; ' + build_env + shlex.join([*numeric_make, 'all']) +
                          '; ' + shlex.join([*numeric_make, '-s', 'print-programs']) +
                          ' > build-numeric/programs; ' +
                          shlex.join(['tar', 'czf', build_directory + '/../' + BUILD_ARCHIVE,
                                      *build['artifacts'], 'build-numeric']))
        if 'numeric' not in profile.get('commands', {}):
            prefix = shlex.join(runner)
            code['numeric'] = ('while IFS= read -r test; do ' + prefix +
                               ' "$test"; done < build-numeric/programs')
    result = {}
    for name, command in code.items():
        setup = cwd + run_setup
        if name == 'build':
            if build.get('host'):
                setup = 'set -eu; cd ' + quote(build_directory) + '; '
            setup += build_env
        result[name] = setup + command
    return result


def passed(stage, exit_code, log):
    import re
    if exit_code != 0:
        return False
    failures = (b'--> test failed!', b'==== FAILING TESTS', b'Assertion failed', b'FACTOR_CORE_FAILURE')
    if any(marker in log for marker in failures):
        return False
    if stage == 'core':
        return bool(re.search(rb'^QEMU_CORE_FAILURES 0\s*$', log, re.M))
    if stage == 'reopen':
        return b'FACTOR_REOPEN_OK' in log
    if stage in ('compiler', 'io', 'ui'):
        return (bool(re.search(rb'^\x00*Unit Test:', log, re.M))
                and not re.search(rb'^==== SKIPPED TESTS: [1-9][0-9]*\s*$', log, re.M))
    return True
