#!/usr/bin/python3
"""Run an explicit command in owned private Linux network/mount namespaces."""
import hashlib, json, os, pathlib, pwd, shutil, signal, subprocess, sys, tempfile, time
base = pathlib.Path(__file__).resolve().parent
if len(sys.argv) < 3:
    raise SystemExit('usage: run-isolated.py LABEL COMMAND [ARGS...]')
uid, gid = os.getuid(), os.getgid()
if uid == 0:
    raise SystemExit('run as the intended unprivileged caller, not root')
user = pwd.getpwuid(uid)
state = pathlib.Path(tempfile.mkdtemp(prefix=sys.argv[1].replace('/', '_') + '-', dir=base))
(state / 'tmp').mkdir()
(state / 'resolv.conf').write_text('nameserver 10.0.2.3\n')
command = sys.argv[2:]
keys = ('QEMU_LD_PREFIX', 'LD_LIBRARY_PATH', 'FACTOR_TEST_CHILD_IMAGE', 'PATH', 'FIXTURE_CALLER_UID')
env = {k: os.environ[k] for k in keys if k in os.environ}
env.update(HOME=user.pw_dir, USER=user.pw_name, LOGNAME=user.pw_name, TMPDIR='/tmp', XDG_CACHE_HOME='/tmp/cache')
def sha(path):
    with open(path, 'rb') as f:
        return hashlib.file_digest(f, 'sha256').hexdigest()
files = [base / 'namespace-root.sh', pathlib.Path(shutil.which(command[0]) or command[0])]
files += [pathlib.Path(a) for a in command[1:] if pathlib.Path(a).is_file()]
for directory in env.get('LD_LIBRARY_PATH', '').split(':'):
    if directory:
        files += list(pathlib.Path(directory).glob('*.so*'))
files += [pathlib.Path(a.split('=', 1)[1]) for a in command if a.startswith('-i=')]
if 'FACTOR_TEST_CHILD_IMAGE' in env:
    files.append(pathlib.Path(env['FACTOR_TEST_CHILD_IMAGE']))
resources = [pathlib.Path(a.split('=', 1)[1]) for a in command if a.startswith('-resource-path=')]
for resource in resources:
    files += [resource / 'factor', resource / 'factor.image', resource / 'libfactor-ffi-test.so']
    for name in ('basis/io/sockets/sockets-tests.factor', 'basis/io/files/unix/unix-tests.factor', 'basis/tools/test/test.factor'):
        files.append(resource / name)
tools = {name: shutil.which(name) for name in ('sudo', 'unshare', 'setpriv', 'nsenter', 'ip', 'slirp4netns')}
record = dict(command=command, cwd=os.getcwd(), environment=env, uid=uid, gid=gid, groups=os.getgroups(),
              started=time.time(), boot_id=pathlib.Path('/proc/sys/kernel/random/boot_id').read_text().strip(),
              hashes={str(p): sha(p) for p in files if p.is_file()},
              tools={k: dict(path=v, sha256=sha(v)) for k,v in tools.items() if v})
resolver = pathlib.Path(env['QEMU_LD_PREFIX']) / 'etc/resolv.conf' if env.get('QEMU_LD_PREFIX') else None
if resolver is not None and resolver.is_file():
    (state / 'resolver-target').write_text(str(resolver.resolve()) + '\n')
    record['resolver_private_bind'] = str(resolver.resolve())
    record['resolver_original_sha256'] = sha(resolver)
(state / 'command.json').write_text(json.dumps(record, indent=2) + '\n')
print(state, flush=True)
p = helper = None
pid = stamp = helper_pid = helper_stamp = None
result = 125
# A PID must still have its recorded start-time before any cleanup signal.
def start_time(n):
    try:
        return pathlib.Path(f'/proc/{n}/stat').read_text().rsplit(')', 1)[1].split()[19]
    except FileNotFoundError:
        return None

def interrupted(signum, frame):
    raise InterruptedError(f'signal {signum}')
for sig in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
    signal.signal(sig, interrupted)
try:
    with open(state / 'output.log', 'w') as log, open(state / 'slirp.log', 'w') as netlog:
        p = subprocess.Popen(['sudo', 'unshare', '--net', '--mount', '--pid', '--fork', str(base / 'namespace-root.sh'), str(state),
                              str(uid), str(gid), ','.join(map(str, os.getgroups())),
                              '/usr/bin/env', *[k+'='+v for k,v in env.items()], *command], stdout=log, stderr=subprocess.STDOUT)
        for _ in range(100):
            if (state / 'ns.pid').exists():
                break
            if p.poll() is not None:
                raise RuntimeError('namespace setup failed')
            time.sleep(.1)
        else:
            raise RuntimeError('namespace setup timeout')
        pid = int((state / 'ns.pid').read_text()); stamp = start_time(pid)
        helper = subprocess.Popen(['sudo', 'slirp4netns', '-c', '-6', str(pid), 'tap0'], stdout=netlog, stderr=subprocess.STDOUT)
        for _ in range(100):
            children = pathlib.Path(f'/proc/{helper.pid}/task/{helper.pid}/children')
            if children.exists() and children.read_text().strip():
                helper_pid = int(children.read_text().split()[0]); helper_stamp = start_time(helper_pid)
            r = subprocess.run(['sudo', 'nsenter', '-t', str(pid), '-n', 'ip', '-4', 'address', 'show', 'tap0'], capture_output=True, text=True)
            if '10.0.2.100' in r.stdout:
                break
            if helper.poll() is not None:
                raise RuntimeError('slirp failed')
            time.sleep(.1)
        else:
            raise RuntimeError('slirp setup timeout')
        record['namespace_pid'] = pid
        record['namespace_start_time'] = stamp
        (state / 'go').touch()
        result = p.wait(timeout=float(os.environ.get('FACTOR_ISOLATION_TIMEOUT', '21600')))
except (Exception, KeyboardInterrupt) as exc:
    record['error'] = repr(exc)
finally:
    for sig in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
        signal.signal(sig, signal.SIG_IGN)
    if p is not None and p.poll() is None:
        if pid is not None and start_time(pid) == stamp:
            subprocess.run(['sudo', 'kill', '-TERM', str(pid)], check=False)
        else:
            p.terminate()
        try:
            p.wait(timeout=5)
        except subprocess.TimeoutExpired:
            if pid is not None and start_time(pid) == stamp:
                subprocess.run(['sudo', 'kill', '-KILL', str(pid)], check=False)
            p.kill(); p.wait()
    if helper is not None and helper.poll() is None:
        if helper_pid is not None and start_time(helper_pid) == helper_stamp:
            subprocess.run(['sudo', 'kill', '-TERM', str(helper_pid)], check=False)
        helper.terminate()
        try:
            helper.wait(timeout=5)
        except subprocess.TimeoutExpired:
            if helper_pid is not None and start_time(helper_pid) == helper_stamp:
                subprocess.run(['sudo', 'kill', '-KILL', str(helper_pid)], check=False)
            helper.kill(); helper.wait()
    record.update(finished=time.time(), exitcode=result)
    (state / 'command.json').write_text(json.dumps(record, indent=2) + '\n')
    (state / 'exitcode').write_text(str(result)+'\n')
raise SystemExit(result)
