import pathlib, subprocess, sys, time
here = pathlib.Path(__file__).resolve().parent
root = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else '/Users/erg/factor.worktrees/allocator-speed-integration')
with (here / 'output.log').open('w') as out:
    process = subprocess.Popen([str(root / 'factor'), '-i=' + str(root / 'speed.factor.image'), '-resource-path=' + str(root), '-no-user-init', str(here / 'repro.factor')], cwd=root, stdout=out, stderr=subprocess.STDOUT)
    while process.poll() is None:
        subprocess.run(['taskpolicy', '-B', '-p', str(process.pid)], capture_output=True)
        time.sleep(1)
    print('exit', process.returncode)
    sys.exit(process.returncode)
