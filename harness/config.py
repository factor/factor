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
        result[key] = merge(result[key], value) if isinstance(value, dict) and isinstance(result.get(key), dict) else deepcopy(value)
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


def validate(profile):
    if not re.fullmatch(r'[a-z0-9][a-z0-9-]*', profile['id']):
        raise ValueError('profile ID must be a simple filename')
    if profile['transport']['kind'] not in ('local', 'ssh', 'serial'):
        raise ValueError('transport must be local, ssh, or serial')
    if not (ROOT / 'vm' / ('Config.' + profile['build']['config'])).is_file():
        raise ValueError('missing VM build configuration')
    if profile.get('stall_seconds', 0) < 0:
        raise ValueError('stall_seconds must be nonnegative; zero disables it')
    for section in ('build', 'execution'):
        for key, value in profile.get(section, {}).get('env', {}).items():
            if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', key) or not isinstance(value, str):
                raise ValueError(f'invalid {section} environment entry: {key}')
    for arg in profile.get('heap', []):
        if not re.fullmatch(r'-(young|aging|tenured)=\d+', arg):
            raise ValueError(f'invalid heap argument: {arg}')
