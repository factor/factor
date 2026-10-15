"""One build and test sequence; profiles supply tools and genuine exceptions."""
import shlex

STAGES = ('build', 'numeric', 'bootstrap', 'reopen', 'core', 'compiler', 'io', 'ui')


def shell_env(values):
    return ''.join('export ' + key + '=' + shlex.quote(value) + '; '
                   for key, value in values.items())


def commands(profile, directory):
    quote = shlex.quote
    build = profile['build']
    make = [build.get('make', 'gmake'), 'CONFIG=vm/Config.' + build['config'],
            'BUILD_DIR=build-validation', '-j' + str(build.get('jobs', 1)),
            *build.get('args', [])]
    factor = [*profile.get('execution', {}).get('runner', []), './factor',
              '-no-user-init', '-resource-path=' + directory, *profile.get('heap', [])]
    normal = shlex.join([*factor, '-i=' + directory + '/factor.image'])
    execution = shell_env(dict(profile.get('execution', {}).get('env', {}),
                               FACTOR_TEST_CHILD_IMAGE=directory + '/factor.image'))
    build_env = shell_env(build.get('env', {}))
    cwd = 'set -eu; cd ' + quote(directory) + '; '
    code = {
        'build': build_env + shlex.join(make + ['factor-executable', 'factor-ffi-test']),
        'numeric': build_env + shlex.join([build.get('make', 'gmake'), '-f',
                    'vm/tests/Makefile.ieee-float', 'BUILD_DIR=build-numeric',
                    'RUNNER=' + shlex.join(profile.get('execution', {}).get('runner', [])), 'check']),
        'bootstrap': shlex.join([*factor, '-i=' + directory + '/boot.image',
                                '-output-image=' + directory + '/factor.image']),
        'reopen': normal + ' ' + quote('-e=USING: io ; "FACTOR_REOPEN_OK" print'),
        'core': normal + ' misc/qemu/core-gate.factor',
        'compiler': normal + ' -run=tools.test compiler',
        'io': shlex.join(profile.get('io_prefix', [])) + ' ' + normal + ' -run=tools.test io',
        'ui': normal + ' -run=tools.test ui',
    }
    code.update(profile.get('commands', {}))
    return {name: cwd + execution + command for name, command in code.items()}


def passed(stage, exit_code, log):
    import re
    if exit_code != 0:
        return False
    failures = (b'--> test failed!', b'==== FAILING TESTS', b'Assertion failed', b'FACTOR_CORE_FAILURE')
    if any(marker in log for marker in failures):
        return False
    if stage == 'core':
        return b'QEMU_CORE_FAILURES 0' in log
    if stage == 'reopen':
        return b'FACTOR_REOPEN_OK' in log
    if stage in ('compiler', 'io', 'ui'):
        return (bool(re.search(rb'^\x00*Unit Test:', log, re.M))
                and not re.search(rb'^==== SKIPPED TESTS: [1-9][0-9]*\s*$', log, re.M))
    return True
