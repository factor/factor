#!/usr/bin/env python3
"""Report native guest validation evidence from the QEMU runner result files."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

SYSTEMS = ('linux', 'freebsd', 'netbsd', 'openbsd', 'dragonfly')
ARCHES = ('x86', 'x64', 'aarch64', 'arm32', 'riscv32', 'riscv64',
          'ppc32', 'ppc64', 'mips32', 'mips64', 'sparc32', 'sparc64',
          'm68k', 'm88k', 's390x', 'alpha', 'hppa', 'sh3', 'sh4', 'vax', 'loongarch64')
PENDING_PORTS = frozenset(ARCHES) - {'x86', 'x64', 'aarch64', 'riscv32', 'riscv64'}
STAGES = ('build', 'unit', 'bootstrap', 'core', 'compiler', 'io', 'vocabtests')
ALIASES = {'x86': 'i386', 'x64': 'amd64', 'aarch64': 'aarch64', 'arm32': 'armv7',
           'ppc32': 'powerpc', 'ppc64': 'powerpc64', 'mips32': 'mips',
           'sparc32': 'sparc', 'm88k': 'luna88k'}
FOUNDATION_ALIASES = {'mips': 'mips32', 'mipsel': 'mips32', 'mips64el': 'mips64',
                      'powerpc': 'ppc32', 'powerpc64': 'ppc64', 'ppc64le': 'ppc64', 'ppc64be': 'ppc64',
                      'ppc.32': 'ppc32', 'ppc.64': 'ppc64', 'ppc.64le': 'ppc64',
                      'm68k.32': 'm68k', 'arm.32': 'arm32', 'armv7': 'arm32',
                      'sparc.32': 'sparc32', 'sparc32plus': 'sparc32', 'sparc.64': 'sparc64',
                      'mips.32': 'mips32', 'mips.64': 'mips64', 'loongarch.64': 'loongarch64', 'physical-sh4-landisk': 'sh4', 'physical-sh3': 'sh3', 'hppa.32': 'hppa', 'sparc32 V8 Sun4m MB86904': 'sparc32', 'physical-sh4-evbsh3': 'sh4'}
SUPPORT = json.loads(Path(__file__).with_name('architecture-support.json').read_text())

def status(value, default='not_run'):
    if isinstance(value, dict):
        value = value.get('status', default)
    if not isinstance(value, str):
        return default
    return {'passed': 'pass', 'failed': 'fail'}.get(value, value)

def read(path):
    if not path.exists():
        return {}
    try:
        document = json.loads(path.read_text())
        if not isinstance(document, dict):
            raise ValueError('result document must be an object')
        return document
    except (OSError, ValueError) as error:
        raise ValueError(f'{path}: {error}') from error

def availability(system, arch):
    return SUPPORT['systems'][system]['architectures'][arch]

def vm_policy(arch):
    policy = SUPPORT['vm_policy']
    return policy['architectures'].get(arch, policy['default'])

def supported(system, arch):
    target = availability(system, arch)
    return target.get('os_port_exists', target['status'] != 'unsupported')

def source(root, system, arch):
    group = 'riscv-linux' if system == 'linux' else 'riscv-bsd'
    return root / (arch if arch in PENDING_PORTS else group if arch.startswith('riscv') else system) / 'results.json'

def stale(revision, *recorded):
    def matches(value):
        if revision == value:
            return True
        # Abbreviated hexadecimal SHAs match; dirty/overlay labels require exact identity.
        return (all(character.lower() in '0123456789abcdef' for character in revision + value)
                and (revision.startswith(value) or value.startswith(revision)))
    return bool(revision and any(value and not matches(value) for value in recorded if isinstance(value, str)))

def running_status(value, detail, path, recovery):
    """Annotate incomplete pre-reboot runs without altering their raw evidence."""
    if value.lower() != 'running' or not recovery:
        return value
    started = detail.get('started_at') if isinstance(detail, dict) else None
    cutoff = recovery['interrupted_before']
    if ((isinstance(started, (int, float)) and started < cutoff)
            or (path.exists() and path.stat().st_mtime < cutoff)):
        return 'interrupted'
    return value

def measurements(record, prefix=''):
    if not isinstance(record, dict):
        return
    if 'status' in record:
        yield prefix or 'overall', record
    for name, value in record.items():
        if name != 'status' and isinstance(value, str) and value.lower() in ('pass', 'passed', 'fail', 'failed', 'pending', 'running', 'partial-pass', 'not_run', 'not-run'):
            yield f'{prefix}.{name}' if prefix else name, {'status': value}
        elif isinstance(value, dict):
            yield from measurements(value, f'{prefix}.{name}' if prefix else name)

def foundation(root, system, arch, revision, cache, recovery=None):
    """Keep ABI-specific bring-up separate from whole-architecture acceptance."""
    registry = read(Path(__file__).with_name('foundation-sources.json')).get('sources', [])
    specifications = {path: {} for path in (
        root / arch / 'foundation.json', root / 'new-linux' / 'foundation.json', root / 'foundation.json',
        *(root / arch).glob('*foundation*.json'), *(root / 'foundation').glob('*.json'))}
    vm_keyed_paths = set()
    for specification in registry:
        for path in root.glob(specification['path']):
            specifications[path] = specification.get('defaults', {})
            if specification.get('variant_format') == 'vm-keyed':
                vm_keyed_paths.add(path)
    variants, seen = [], {}
    for path, defaults in sorted(specifications.items()):
        if path not in cache:
            cache[path] = read(path)
        document = cache[path]
        if not document:
            continue
        # A registered live owner manifest supersedes its copied snapshot.
        if document.get('original_results_path') and Path(document['original_results_path']) in specifications:
            continue
        entries = document.get('variants', document.get('cells', [document] if defaults or document.get('os') else []))
        keyed = isinstance(entries, dict) and path in vm_keyed_paths
        if keyed:
            required = {'vm', 'source_revision', 'build', 'native_runtime_probe', 'compiler', 'io'}
            if set(entries) != {'cpp', 'zig'} or any(
                    not isinstance(record, dict) or not required.issubset(record)
                    or not isinstance(record['source_revision'], str)
                    or any(not isinstance(record[stage], dict) for stage in required - {'source_revision'})
                    or any(not isinstance(record[stage].get('status'), str) for stage in ('build', 'native_runtime_probe', 'compiler', 'io'))
                    for record in entries.values()):
                raise ValueError(f'{path}: malformed cpp/zig VM-keyed foundation variants')
            entries = [{'id': f"{defaults.get('id', path.stem)}-{vm}",
                        'source_revision': record['source_revision'], 'vm_revision': record['source_revision'], vm: record}
                       for vm, record in entries.items()]
        if not isinstance(entries, list):
            raise ValueError(f'{path}: foundation variants must be a list')
        for index, original in enumerate(entries):
            if not isinstance(original, dict):
                raise ValueError(f'{path}: foundation record must be an object')
            variant = dict(original, **({k: v for k, v in defaults.items() if k != 'id'} if keyed else defaults))
            variant.setdefault('arch', variant.get('cpu', variant.get('architecture', document.get('architecture'))))
            variant.setdefault('endian', variant.get('byte_order', document.get('endian', document.get('endianness'))))
            variant.setdefault('abi', variant.get('userland_abi', document.get('abi')))
            variant.setdefault('vm_revision', variant.get('vm_build_revision'))
            variant.setdefault('source_revision', document.get('source_revision'))
            recorded_os = variant.get('os', '')
            variant['os'] = next((name for name in SYSTEMS if str(recorded_os).lower().startswith(name)), recorded_os)
            if variant.get('os') != system or FOUNDATION_ALIASES.get(variant.get('arch'), variant.get('arch')) != arch:
                continue
            variant.setdefault('id', variant.get('variant') or f'{path.relative_to(root)}#{index}')
            variant.setdefault('pointer_bits', variant.get('pointer_width', document.get('pointer_bits', document.get('pointer_bytes', 0) * 8 or None)))
            variant.setdefault('release', variant.get('os_release'))
            identity = (variant['id'], variant.get('source_revision'), variant.get('vm_revision'), variant.get('image_source_revision'),
                        variant.get('cpp_source_revision'), variant.get('zig_source_revision'))
            if identity in seen:
                previous, previous_path = seen[identity]
                if previous != variant:
                    raise ValueError(f'conflicting foundation record {identity}: {previous_path} and {path}')
                continue
            seen[identity] = (dict(variant), path)
            variant['results_path'] = str(path)
            if 'variants' in document or 'cells' in document:
                variant['document_provenance'] = document if keyed else {key: value for key, value in document.items() if key not in ('variants', 'cells')}
            identity_fields = ('os', 'arch', 'cpu', 'architecture', 'endian', 'byte_order', 'abi', 'userland_abi')
            variant['recorded_identity'] = {key: original[key] for key in identity_fields if key in original}
            variant_revision = variant.get('source_revision', document.get('source_revision'))
            variant['stale'] = stale(revision, variant_revision, variant.get('vm_revision'), variant.get('image_source_revision'), variant.get('cpp_source_revision'), variant.get('zig_source_revision'))
            variant['reported'] = {}
            for implementation in ('cpp', 'zig', 'foundation'):
                stages = variant.get(implementation, {}) if implementation != 'foundation' else {k: v for k, v in original.items() if k not in ('cpp', 'zig')}
                reported = {}
                for stage, detail in measurements(stages):
                    value = status(detail)
                    if value in ('PASS', 'PASSED', 'FAIL', 'FAILED', 'RUNNING', 'NOT_RUN', 'PARTIAL-PASS'):
                        value = status(value.lower())
                    value = running_status(value, detail, path, recovery)
                    if stage.split('.')[-1] in ('unit', 'bridge_unit') and value == 'pass' and not detail.get('complete_suite'):
                        value = 'partial-pass'
                    stage_stale = stale(revision, detail.get('source_revision', variant_revision), detail.get('vm_source_revision', detail.get('vm_revision', variant.get('vm_revision'))), detail.get('image_source_revision'),
                                        variant.get(f'{implementation}_source_revision'),
                                        variant.get('cpp_source_revision') if implementation == 'foundation' else None,
                                        variant.get('zig_source_revision') if implementation == 'foundation' else None,
                                        variant.get('guest_source_revision'), variant.get('resource_source_revision'))
                    reported[stage] = 'stale' if stage_stale and value in ('pass', 'partial-pass') else value
                variant['reported'][implementation] = reported
            variants.append(variant)
    return variants

def vm_artifact(document, implementation):
    artifacts = document.get('artifacts', {})
    return artifacts.get(implementation, artifacts.get(implementation + '-vm', {}))

def supplemental(root, system, arch, revision, cache, recovery=None):
    proofs = []
    for path in sorted((root / 'acceptance').glob('host-*/result.json')):
        if path not in cache:
            cache[path] = read(path)
        document = cache[path]
        if document.get('os') != system or document.get('arch') != arch:
            continue
        proof = dict(document, results_path=str(path), reported={})
        for implementation in ('cpp', 'zig'):
            artifact = vm_artifact(document, implementation)
            proof['reported'][implementation] = {}
            for stage, detail in document.get(implementation, {}).items():
                if not isinstance(detail, dict) or 'status' not in detail:
                    continue
                value = running_status(status(detail), detail, path, recovery)
                revisions = (detail.get('source_revision', document.get('source_revision')), artifact.get('source_revision')) if isinstance(detail, dict) else (document.get('source_revision'), artifact.get('source_revision'))
                proof['reported'][implementation][stage] = 'stale' if value == 'pass' and stale(revision, *revisions) else value
        proofs.append(proof)
    return proofs

def rows(root, revision=None):
    cache = {}
    recovery = read(root / 'report-recovery.json')
    if recovery and (recovery.get('boot_id') != Path('/proc/sys/kernel/random/boot_id').read_text().strip()
                     or not isinstance(recovery.get('interrupted_before'), (int, float))):
        raise ValueError('report-recovery.json must describe the current host boot and numeric interruption time')
    result = []
    for system in SYSTEMS:
        for arch in ARCHES:
            path = source(root, system, arch)
            if path not in cache:
                cache[path] = read(path)
            document = cache[path]
            if 'systems' in document:
                document = document['systems'].get(system, {})
            entry = dict(document.get('architectures', {}).get(arch, {}))
            acceptance = None
            acceptance_names = (
                f'{system}-{name}'
                for system in ((system, 'dragonflybsd') if system == 'dragonfly' else (system,))
                for name in dict.fromkeys((arch, ALIASES.get(arch, arch), 'arm64' if arch == 'aarch64' else arch))
            )
            for name in acceptance_names:
                for filename in ('result.json', 'results.json'):
                    candidate = root / 'acceptance' / name / filename
                    if candidate.exists():
                        acceptance = read(candidate)
                        break
                if acceptance is not None:
                    break
            if system == 'linux' and arch == 'loongarch64':
                bundle_path = root / 'loongarch' / 'completed-prefixes-review.json'
                review_path = root / 'loongarch' / 'root-full-prefix-complete-review.json'
                if bundle_path.exists() and review_path.exists():
                    bundle, review = read(bundle_path), read(review_path)
                    import hashlib
                    if (not review.get('all_required_full_prefixes_pass')
                            or hashlib.sha256(bundle_path.read_bytes()).hexdigest() != review.get('bundle_sha256')):
                        raise ValueError(f'{review_path}: incomplete or conflicting completed-prefix bundle')
                    acceptance = dict(bundle, root_review=review, source_revision=None)
                    required_vms = vm_policy(arch)['required']
                    for implementation in ('cpp', 'zig'):
                        variant = bundle.get('variants', {}).get(implementation, {})
                        acceptance[implementation] = {}
                        for stage in ('compiler', 'io'):
                            detail = variant.get(stage, {})
                            if status(detail).lower() != 'pass' or detail.get('exit_code') != 0 or not detail.get('source_revision'):
                                if implementation in required_vms:
                                    raise ValueError(f'{bundle_path}: incomplete {implementation}/{stage}')
                                # Optional VM evidence remains visible without
                                # making an incomplete pass an acceptance gate.
                                if detail and status(detail).lower() != 'pass':
                                    acceptance[implementation][stage] = dict(detail, vm_source_revision=variant.get('vm_source_revision'))
                                continue
                            acceptance[implementation][stage] = dict(detail, status='pass', vm_source_revision=variant.get('vm_source_revision'))
                    candidate = bundle_path
            if acceptance is not None:
                for implementation in ('cpp', 'zig'):
                    merged = dict(entry.get(implementation, {}))
                    for stage, value in acceptance.get(implementation, {}).items():
                        detail = dict(value) if isinstance(value, dict) else {'status': value}
                        detail.setdefault('source_revision', acceptance.get('source_revision'))
                        detail.setdefault('recorded_in', str(candidate))
                        merged[stage] = detail
                    entry[implementation] = merged
            support = supported(system, arch)
            target = availability(system, arch)
            planned = target.get('port_state') == 'proposed'
            default = 'pending-port' if planned else 'unsupported' if not support else 'pending-port' if arch in PENDING_PORTS else 'not_run'
            row = {'os': system, 'arch': arch, 'release': target.get('release', document.get('release', SUPPORT['systems'][system]['release'])), 'supported': support, 'planned': planned,
                   'availability': availability(system, arch), 'vm_policy': vm_policy(arch),
                   'guest': status(entry.get('guest'), default), 'results_path': str(path),
                   'acceptance_path': str(candidate) if acceptance is not None else None,
                   'acceptance_provenance': {key: value for key, value in acceptance.items() if key not in ('cpp', 'zig')} if acceptance is not None else None,
                   'backup_manifest': {'path': str(candidate.parent / 'backup' / 'manifest.json'),
                                       'evidence': read(candidate.parent / 'backup' / 'manifest.json')}
                                      if acceptance is not None and (candidate.parent / 'backup' / 'manifest.json').exists() else None,
                   'source_revision': document.get('source_revision'), 'updated_at': document.get('updated_at'),
                   'foundation': foundation(root, system, arch, revision, cache, recovery),
                   'recovery_context': recovery or None,
                   'supplemental_acceptance': supplemental(root, system, arch, revision, cache, recovery),
                   'evidence': entry, 'stale': stale(revision, document.get('source_revision'))}
            for implementation in ('cpp', 'zig'):
                stages = entry.get(implementation, {})
                row[implementation] = {}
                for stage in STAGES:
                    detail = stages.get(stage)
                    stage_revision = detail.get('source_revision', document.get('source_revision')) if isinstance(detail, dict) else document.get('source_revision')
                    stage_stale = stale(revision, stage_revision)
                    implementation_default = 'unsupported' if implementation == 'zig' and vm_policy(arch)['zig'] == 'unsupported' else default
                    value = status(detail, implementation_default)
                    recorded_in = Path(detail.get('recorded_in', path)) if isinstance(detail, dict) else path
                    value = running_status(value, detail, recorded_in, recovery)
                    row[implementation][stage] = 'stale' if stage_stale and value == 'pass' else value
            result.append(row)
    return result

def runner(system, arch):
    if arch.startswith('riscv'):
        return ('riscv-linux.py', [arch]) if system == 'linux' else ('riscv-bsd.py', [system, arch])
    guest_arch = ALIASES.get(arch, arch)
    if system == 'linux' and arch == 'aarch64':
        guest_arch = 'arm64'
    return system + '.py', [guest_arch]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(os.environ.get('FACTOR_QEMU_MATRIX_DIR', '/home/sheeple/factor/work/qemu-matrix')))
    parser.add_argument('--working-source', action='store_true', help='report checkout tracked patch fingerprint; compare to recorded stage fingerprints')
    parser.add_argument('--revision', help='expected source revision; defaults to checkout HEAD')
    parser.add_argument('--json', action='store_true', help='emit all stage evidence and result paths as JSON')
    parser.add_argument('--os', choices=SYSTEMS)
    parser.add_argument('--arch', choices=ARCHES)
    parser.add_argument('--supplemental', action='store_true', help='show separate historical host proof; does not overlay canonical guest acceptance')
    parser.add_argument('--foundation', action='store_true', help='show ABI-specific VM bring-up without promoting it to compiler/io acceptance')
    parser.add_argument('--commands', action='store_true', help='show commands recorded in guest/stage evidence')
    parser.add_argument('--run', nargs=argparse.REMAINDER, metavar='COMMAND', help='run the selected OS runner; requires --os and --arch')
    sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
    from harness import cli
    cli.arguments(parser)
    args = parser.parse_args()
    if args.profiles or args.profile:
        return cli.main(args, parser)
    if args.run is not None:
        if not args.os or not args.arch or not args.run:
            parser.error('--run requires --os, --arch, and a runner action')
        if not supported(args.os, args.arch):
            parser.error('this OS does not support this architecture')
        if args.arch in PENDING_PORTS:
            parser.error('this architecture has guest-specific launch commands; use --commands to inspect recorded evidence')
        script, target = runner(args.os, args.arch)
        script_path = Path(__file__).resolve().parent / script
        if not script_path.exists():
            parser.error(f'runner is not installed: {script_path}')
        action = 'boot' if args.os == 'openbsd' and args.run[0] == 'start' else args.run[0]
        asset_group = 'riscv-linux' if args.arch.startswith('riscv') and args.os == 'linux' else 'riscv-bsd' if args.arch.startswith('riscv') else args.os
        assets = args.root.resolve() / asset_group
        command = [args.os, action, '--assets', str(assets), *args.run[1:]] if script == 'riscv-bsd.py' else [action, *target, *args.run[1:]]
        env = os.environ.copy()
        env.update(FACTOR_QEMU_LINUX_DIR=str(assets), FACTOR_QEMU_RISCV_DIR=str(assets), OPENBSD_ASSETS=str(assets))
        if args.os in ('freebsd', 'netbsd', 'dragonfly') and not args.arch.startswith('riscv'):
            command[2:2] = ['--assets', str(assets)]
        return subprocess.call([sys.executable, str(script_path), *command], env=env)
    try:
        revision = args.revision
        if revision is None:
            probe = subprocess.run(['git', 'rev-parse', 'HEAD'], cwd=Path(__file__).resolve().parent, capture_output=True, text=True)
            revision = probe.stdout.strip() if probe.returncode == 0 else None
        records = [r for r in rows(args.root, revision) if (not args.os or r['os'] == args.os) and (not args.arch or r['arch'] == args.arch)]
    except ValueError as error:
        parser.error(str(error))
    checkout = Path(__file__).resolve().parents[2]
    patch = subprocess.run(['git', 'diff', 'HEAD', '--binary'], cwd=checkout, capture_output=True).stdout
    fingerprint = hashlib.sha256(patch).hexdigest()
    working_source = {'source_revision': revision, 'tracked_diff_sha256': fingerprint, 'tracked_changes': bool(patch)}
    if args.working_source:
        for row in records:
            for implementation in ('cpp', 'zig'):
                for stage in STAGES:
                    detail = row['evidence'].get(implementation, {}).get(stage)
                    recorded = detail.get('tracked_diff_sha256') if isinstance(detail, dict) else None
                    if row[implementation][stage] == 'pass' and ((recorded and recorded != fingerprint) or (patch and not recorded)):
                        row[implementation][stage] = 'stale' if recorded else 'unverified-source'
    if args.json:
        print(json.dumps({'schema_version': 1, 'working_source': working_source, 'rows': records}, indent=2))
        return 0
    if args.supplemental:
        for row in records:
            for proof in row['supplemental_acceptance']:
                print(f"{row['os']}/{row['arch']} supplemental: {proof['results_path']}")
                print('  vocabulary source: ' + str(proof.get('source_revision')))
                for implementation, stages in proof['reported'].items():
                    print(f"  {implementation} VM: {vm_artifact(proof, implementation).get('source_revision')}")
                    for stage, value in stages.items():
                        detail = proof[implementation][stage]
                        print(f"  {implementation}/{stage}: {value}; log={detail.get('log')}")
                        for key in ('exit_code', 'exitcode', 'unit_test_markers', 'unit_test_count', 'must_fail_markers', 'negative_check_count', 'scope'):
                            if key in detail:
                                print(f'    {key}: {detail[key]}')
        return 0
    if args.foundation:
        count = 0
        for row in records:
            for variant in row['foundation']:
                count += 1
                print(f"{row['os']}/{row['arch']} {variant.get('id', '(unnamed variant)')}: "
                      f"ABI={variant.get('abi', 'unrecorded')} endian={variant.get('endian', 'unrecorded')} "
                      f"pointer_bits={variant.get('pointer_bits', 'unrecorded')}")
                print('  evidence: ' + variant['results_path'])
                if variant['stale']:
                    print('  source: stale for requested revision')
                for implementation, stages in variant['reported'].items():
                    for stage, value in stages.items():
                        detail = dict(measurements(variant if implementation == 'foundation' else variant[implementation]))[stage]
                        print(f"  {implementation}/{stage}: {value}")
                        if isinstance(detail, dict):
                            for key in ('scope', 'source_revision', 'command', 'log', 'sha256', 'tracked_diff_sha256', 'passed', 'skipped', 'failed', 'summary', 'results', 'vm_revision', 'image_source_revision', 'compiler_revision', 'execution'):
                                if detail.get(key) is not None:
                                    print(f"    {key}: {detail[key]}")
                for key in ('source_revision', 'release', 'guest', 'probe', 'foundation_status', 'probe_command', 'probe_log', 'probe_source_sha256', 'qemu_command', 'qemu_running', 'status', 'scope', 'command', 'log', 'binary', 'sha256', 'native_foundation_pass', 'factor_vm_pass', 'boot_mode', 'compiler', 'state', 'llvm_commit', 'zig_commit', 'artifacts_sha256', 'logs', 'evidence', 'limitations', 'image', 'boot_image', 'frozen_factor_source', 'guest_kernel', 'native_compiler', 'document_provenance', 'cross_compiler', 'vm_sha256', 'image_sha256', 'image_sha512', 'vm_revision', 'image_revision', 'source_dirty_patch', 'blocker', 'milestones', 'routes', 'native_double', 'native_g_float_conversion', 'probe_commits', 'float_commits', 'cpp_source_revision', 'zig_source_revision', 'boot_image_sha256', 'bootstrap_log', 'native_signal_probe_log', 'guest_source_revision', 'seed_source_revision', 'resource_source_revision'):
                    if variant.get(key) is not None:
                        print(f"  {key}: {json.dumps(variant[key], sort_keys=True)}")
        if not count:
            print('No ABI-specific foundation evidence recorded.')
        return 0
    headings = ['OS', 'ARCH', 'REQUIRED', 'GUEST', *('C++/' + s for s in STAGES), *('Zig/' + s for s in STAGES)]
    table = [headings] + [[r['os'], r['arch'], '+'.join(r['vm_policy']['required']), r['guest'], *r['cpp'].values(), *r['zig'].values()] for r in records]
    widths = [max(len(str(row[i])) for row in table) for i in range(len(headings))]
    for row in table:
        print('  '.join(str(value).ljust(width) for value, width in zip(row, widths)).rstrip())
    if args.commands:
        for row in records:
            print(f"\n{row['os']}/{row['arch']}: {row['results_path']}")
            evidence = row['evidence']
            guest = evidence.get('guest', {})
            if isinstance(guest, dict) and guest.get('command'):
                print('  guest: ' + guest['command'])
            for implementation in ('cpp', 'zig'):
                for stage, detail in evidence.get(implementation, {}).items():
                    if isinstance(detail, dict):
                        if detail.get('command'):
                            print(f"  {implementation}/{stage}: {detail['command']}")
                        if detail.get('log'):
                            print(f"  log: {detail['log']}")
    return 0

if __name__ == '__main__':
    sys.exit(main())
