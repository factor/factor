"""Profile commands used by the existing QEMU matrix entry point."""
from datetime import datetime, timezone
import json
from pathlib import Path

from .config import ROOT, load, profiles
from .runner import execute, plan
from .stages import STAGES


def arguments(parser):
    parser.add_argument('--profiles', action='store_true', help='list qualification profile IDs')
    parser.add_argument('--profile', help='select an OS/CPU/ABI qualification profile')
    parser.add_argument('--site', type=Path, help='JSON machine-local profile overrides')
    parser.add_argument('--output', type=Path, help='new run directory, or an existing run with --resume')
    parser.add_argument('--seed', type=Path, help='boot image; defaults to boot.<profile seed>.image')
    parser.add_argument('--resume', action='store_true', help='resume matching source/profile/seed; retain old attempts')
    parser.add_argument('--stages', nargs='+', choices=STAGES, default=STAGES, help='run selected stages; a subset is partial validation')
    parser.add_argument('--dry-run', action='store_true', help='render profile commands without launching anything')


def main(args, parser):
    if args.profiles:
        names = sorted(profiles())
        print(json.dumps(names, indent=2) if args.json else '\n'.join(names))
        return 0
    try:
        profile = load(args.profile, args.root, args.site)
        if args.run is None or args.dry_run:
            result = plan(profile)
            if args.output and (args.output / 'run.json').exists():
                result['recorded_run'] = json.loads((args.output / 'run.json').read_text())
                result['recorded_run_scope'] = 'Recorded evidence; not a current-source qualification claim.'
            print(json.dumps(result, indent=2))
            return 0
        if args.run != ['validate']:
            parser.error('profiles support --run validate; omit --run to inspect commands')
        if args.resume and args.output is None:
            parser.error('--resume requires --output')
        output = args.output or args.root / 'runs' / (args.profile + '-' +
                 datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ'))
        seed = args.seed or ROOT / ('boot.' + profile['seed'] + '.image')
        result = execute(profile, output, seed, resume=args.resume, stages=args.stages)
        print(json.dumps(result, indent=2))
        return 0 if result['status'] in ('pass', 'partial') else 1
    except (OSError, ValueError, RuntimeError) as error:
        parser.exit(1, str(error) + '\n')
