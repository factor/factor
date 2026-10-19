#!/usr/bin/env python3
import os
"""FreeBSD 14.5 QEMU guests for both Factor VMs.

SSH uses a per-run ed25519 key. Initial login on stock images is root with an
empty password; enable sshd and install the public key through the console.
Downloads are verified against the release server's SHA256 manifest.
"""
import argparse, hashlib, json, os, pathlib, shlex, subprocess, urllib.request
ROOT = pathlib.Path(__file__).resolve().parents[2]
ARCH = {'amd64': ('x86_64', 22200, 'freebsd-x86-64', 'x86.64'), 'i386': ('i386', 22201, 'freebsd-x86-32', 'x86.32'), 'aarch64': ('aarch64', 22202, 'freebsd-arm-64', 'arm.64')}
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('action', choices=['setup','start','status','ssh','probe','build','bootstrap','test'])
p.add_argument('arch', choices=ARCH)
p.add_argument('command', nargs='?', default='uname -a')
p.add_argument('--assets', type=pathlib.Path, default=pathlib.Path(os.environ.get('FACTOR_QEMU_MATRIX_DIR',str(ROOT/'work/qemu-matrix')))/'freebsd')
p.add_argument('--vm', choices=['cpp','zig'], default='cpp')
p.add_argument('--image', default='/root/factor/factor.image')
p.add_argument('--zig', default='zig')
a = p.parse_args(); a.assets.mkdir(parents=True, exist_ok=True)
emulator, port, target, boot = ARCH[a.arch]
name = 'FreeBSD-14.5-RELEASE-'+('arm64-aarch64' if a.arch=='aarch64' else a.arch)+'-ufs.qcow2'
def ssh(command):
    return subprocess.run(['ssh','-i',str(a.assets/'id_ed25519'),'-o','StrictHostKeyChecking=no','-o','UserKnownHostsFile=/dev/null','-p',str(port),'root@127.0.0.1',command]).returncode
if a.action=='setup':
    url=f'https://download.freebsd.org/releases/VM-IMAGES/14.5-RELEASE/{a.arch}/Latest/'
    archive=a.assets/(name+'.xz')
    if not archive.exists(): urllib.request.urlretrieve(url+archive.name, archive)
    checks=urllib.request.urlopen(url+'CHECKSUM.SHA256').read().decode()
    (a.assets/(a.arch+'-CHECKSUM.SHA256')).write_text(checks)
    with archive.open('rb') as f: digest=hashlib.file_digest(f,'sha256').hexdigest()
    assert any(archive.name in line and digest in line for line in checks.splitlines()), 'SHA256 mismatch'
    if not (a.assets/name).exists(): subprocess.run(['xz','-dk',str(archive)],check=True)
if a.action in ('setup','start'):
    disk=a.assets/(a.arch+'.qcow2')
    if not disk.exists(): subprocess.run(['qemu-img','create','-f','qcow2','-F','qcow2','-b',str((a.assets/name).resolve()),str(disk),'20G'],check=True)
    cmd=['qemu-system-'+emulator,'-m','2048','-smp','2','-display','none','-monitor',f'unix:{a.assets}/{a.arch}.monitor,server=on,wait=off','-serial',f'unix:{a.assets}/{a.arch}.sock,server=on,wait=off','-drive',f'file={disk},if=virtio,format=qcow2','-netdev',f'user,id=net,hostfwd=tcp:127.0.0.1:{port}-:22','-device','virtio-net-pci,netdev=net','-pidfile',str(a.assets/(a.arch+'.pid')),'-daemonize']
    if a.arch=='aarch64': cmd+=['-machine','virt','-cpu','cortex-a72','-bios','/usr/share/AAVMF/AAVMF_CODE.fd']
    else: cmd=['sg','kvm','-c',shlex.join(cmd+['-accel','kvm','-cpu','host'])]
    (a.assets/(a.arch+'-command.json')).write_text(json.dumps(cmd,indent=2)+'\n')
    raise SystemExit(subprocess.run(cmd).returncode)
if a.action=='status':
    pid=a.assets/(a.arch+'.pid')
    running=pid.exists() and pathlib.Path('/proc/'+pid.read_text().strip()).exists()
    print(json.dumps({'arch':a.arch,'running':running,'ssh_port':port})); raise SystemExit(0 if running else 1)
if a.action=='build' and a.vm=='zig':
    zig_target={'amd64':'x86_64','i386':'x86','aarch64':'aarch64'}[a.arch]+'-freebsd'
    command=[a.zig,'build','-j2','-Dtarget='+zig_target,'-Doptimize=ReleaseFast','-Dcopy-to-root=false','-Dlibc-file='+str(a.assets/(a.arch+'.libc')),'--sysroot',str(a.assets/('sysroot-'+a.arch)),'--prefix',str(a.assets/('zig-'+a.arch))]
    result = subprocess.run(command, cwd=ROOT)
    if result.returncode:
        raise SystemExit(result.returncode)
    executable = a.assets / ('zig-' + a.arch) / 'bin/factor'
    subprocess.run(['scp', '-i', str(a.assets/'id_ed25519'),
                    '-o', 'StrictHostKeyChecking=no', '-o', 'UserKnownHostsFile=/dev/null',
                    '-P', str(port), str(executable),
                    'root@127.0.0.1:/root/factor/factor-zig.new'], check=True)
    raise SystemExit(ssh('mv /root/factor/factor-zig.new /root/factor/factor-zig'))
vm='./factor' if a.vm=='cpp' else './factor-zig'
image = a.image if a.image.startswith('/') else '/root/factor/' + a.image
commands={'ssh':a.command,'probe':'uname -a; freebsd-version; c++ --version | head -1','build':'cd /root/factor; gmake -j2 '+target,'bootstrap':f'cd /root/factor; {vm} -i=/root/factor/boot.image -resource-path=/root/factor -no-ui -include="math compiler threads io tools unicode"','test':f'cd /root/factor; FACTOR_TEST_CHILD_IMAGE={shlex.quote(image)} {vm} -i={shlex.quote(image)} -resource-path=/root/factor -no-user-init -no-monitors -run=tools.test resource:core compiler threads io alien'}
raise SystemExit(ssh(commands[a.action]))
