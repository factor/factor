"""Target profiles are data; machine-local paths can be supplied separately."""
from copy import deepcopy
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PROFILES = Path(__file__).with_name('profiles.json')


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest()


def merge(base, changes):
    result = deepcopy(base)
    for key, value in changes.items():
        if isinstance(value, dict) and isinstance(result.get(key), dict):
            result[key] = merge(result[key], value)
        else:
            result[key] = deepcopy(value)
    return result


def profiles(path=PROFILES):
    document = json.loads(Path(path).read_text())
    return {name: merge(document.get('defaults', {}), value)
            for name, value in document['targets'].items()}


def load(name, assets, site=None, path=PROFILES):
    targets = profiles(path)
    if name not in targets:
        raise ValueError(f'unknown profile: {name}')
    profile = targets[name]
    if site:
        overrides = json.loads(Path(site).read_text())
        profile = merge(profile, overrides.get('defaults', {}))
        profile = merge(profile, overrides.get('targets', {}).get(name, {}))
    replacements = {'repo': str(ROOT), 'assets': str(Path(assets).resolve())}

    def expand(value):
        if isinstance(value, str):
            for key, replacement in replacements.items():
                value = value.replace('${' + key + '}', replacement)
            return value
        if isinstance(value, list):
            return [expand(item) for item in value]
        if isinstance(value, dict):
            return {key: expand(item) for key, item in value.items()}
        return value

    profile = expand(profile)
    profile['id'] = name
    profile['assets'] = str(Path(assets).resolve())
    validate(profile)
    return profile


def is_relative_path(value):
    """A lexical path below the run directory, without parent traversal."""
    return (isinstance(value, str) and bool(value) and value != '.' and
            not Path(value).is_absolute() and '..' not in Path(value).parts)


def validate(profile):
    if not re.fullmatch(r'[a-z0-9][a-z0-9-]*', profile['id']):
        raise ValueError('profile ID must be a simple filename')
    if profile['transport']['kind'] not in ('local', 'ssh', 'adb', 'serial'):
        raise ValueError('transport must be local, ssh, adb, or serial')
    if profile['transport']['kind'] == 'adb':
        argv = profile['transport'].get('argv', [])
        serial_index = argv.index('-s') + 1 if '-s' in argv else len(argv)
        if serial_index >= len(argv) or not argv[serial_index]:
            raise ValueError('ADB transport requires an explicit -s device serial')
    if not (ROOT / 'vm' / ('Config.' + profile['build']['config'])).is_file():
        raise ValueError('missing VM build configuration')
    stall_seconds = profile.get('stall_seconds', 0)
    if not isinstance(stall_seconds, (int, float)) or stall_seconds < 0:
        raise ValueError('stall_seconds must be nonnegative; zero disables it')
    for section in ('build', 'execution'):
        for key, value in profile.get(section, {}).get('env', {}).items():
            if (not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', key) or
                    not isinstance(value, str)):
                raise ValueError(f'invalid {section} environment entry: {key}')
    for key, value in profile.get('execution', {}).get('directories', {}).items():
        if (not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', key) or
                not is_relative_path(value)):
            raise ValueError('execution directories must be relative paths inside the run directory')
    if profile['build'].get('host'):
        artifacts = profile['build'].get('artifacts')
        if not isinstance(artifacts, list) or not artifacts:
            raise ValueError('host builds must list the artifacts to upload')
        for name in artifacts:
            if not is_relative_path(name):
                raise ValueError('build artifacts must be relative paths inside the build directory')
    validate_guest(profile.get('guest'))
    for arg in profile.get('heap', []):
        if not re.fullmatch(r'-(young|aging|tenured)=\d+', arg):
            raise ValueError(f'invalid heap argument: {arg}')


def validate_guest(guest):
    if not guest:
        return
    if guest.get('kind', 'qemu') not in ('qemu', 'command'):
        raise ValueError('guest kind must be qemu or command')
    argv = guest.get('argv')
    if (not isinstance(argv, list) or not argv or
            not all(isinstance(arg, str) for arg in argv)):
        raise ValueError('guest argv must be a nonempty list of strings')
    for drive in guest.get('drives', []) + guest.get('scratch_drives', []):
        options = drive.get('options', '')
        if any(part.split('=')[0] in ('file', 'format') or part.startswith('file.')
               for part in options.split(',')):
            raise ValueError('drive options cannot override the private file or format')
        if 'file' in drive and drive.get('format') not in ('raw', 'qcow2'):
            raise ValueError('backing drive format must be raw or qcow2')
    validate_guest(guest.get('outer', {}).get('guest'))
