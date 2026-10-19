#!/usr/bin/env python3
import os
"""Debian 12 QEMU Linux matrix; all forwarded SSH sockets bind localhost.
Run prepare amd64|arm64, start ARCH, ssh ARCH COMMAND, or stop ARCH.
Use --foreground start ARCH when running inside a host-job VM service.
Assets default to work/qemu-matrix/linux; override FACTOR_QEMU_LINUX_DIR.
"""
import argparse,json,os,pathlib,shlex,signal,subprocess,time,shutil
D=pathlib.Path(os.environ.get('FACTOR_QEMU_LINUX_DIR',os.path.join(os.environ.get('FACTOR_QEMU_MATRIX_DIR','/home/sheeple/factor/work/qemu-matrix'),'linux')))
PORT={'amd64':22100,'arm64':22101,'i386':22102}
def run(cmd,**kw): return subprocess.run(cmd,check=True,**kw)
def sshcmd(a): return ['ssh','-i',str(D/'id_ed25519'),'-p',str(PORT[a]),'-o','StrictHostKeyChecking=no','-o','UserKnownHostsFile=/dev/null','-o','ConnectTimeout=20','factor@127.0.0.1']
def prepare(a):
    D.mkdir(parents=True,exist_ok=True)
    if not (D/'id_ed25519').exists(): run(['ssh-keygen','-q','-t','ed25519','-N','','-f',str(D/'id_ed25519')])
    if a=='i386':
        prepare_i386(); return
    base=D/f'{a}-base.qcow2'
    if not base.exists():
        run(['curl','-L','--fail','--retry','3',f'https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-{a}.qcow2','-o',str(base)])
    key=(D/'id_ed25519.pub').read_text().strip()
    user='#cloud-config\nusers:\n  - name: factor\n    shell: /bin/bash\n    sudo: ALL=(ALL) NOPASSWD:ALL\n    ssh_authorized_keys:\n      - '+key+'\nssh_pwauth: false\npackage_update: true\npackages: [g++, make, libpango-1.0-0, libx11-6, libgl1, libssl-dev, ca-certificates]\n'
    (D/f'{a}-user-data').write_text(user)
    (D/f'{a}-meta-data').write_text(f'instance-id: factor-{a}\nlocal-hostname: factor-{a}\n')
    run(['cloud-localds',str(D/f'{a}-seed.iso'),str(D/f'{a}-user-data'),str(D/f'{a}-meta-data')])
    if not (D/f'{a}.qcow2').exists():
        run(['qemu-img','create','-f','qcow2','-F','qcow2','-b',str(D/f'{a}-base.qcow2'),str(D/f'{a}.qcow2'),'24G'])
def prepare_i386():
    if (D/'i386.raw').exists():
        return
    root=D/'i386-root'
    if not (root/'boot').exists():
        run(['sudo','-n','debootstrap','--arch=i386','--include=linux-image-686,openssh-server,sudo,g++,make,libpango-1.0-0,libx11-6,libgl1,libssl-dev,ca-certificates','bookworm',str(root),'https://deb.debian.org/debian'])
    run(['sudo','-n','chroot',str(root),'sh','-c','id factor >/dev/null 2>&1 || useradd -m -s /bin/bash factor'])
    files={'etc/sudoers.d/factor':'factor ALL=(ALL) NOPASSWD:ALL\n','etc/network/interfaces':'auto lo\niface lo inet loopback\nauto eth0\niface eth0 inet dhcp\n','etc/hostname':'factor-i386\n','etc/fstab':'/dev/vda / ext4 defaults 0 1\n','home/factor/.ssh/authorized_keys':(D/'id_ed25519.pub').read_text()}
    for name,value in files.items():
        dest=root/name
        run(['sudo','-n','mkdir','-p',str(dest.parent)])
        run(['sudo','-n','tee',str(dest)],input=value.encode(),stdout=subprocess.DEVNULL)
    run(['sudo','-n','chroot',str(root),'chown','-R','factor:factor','/home/factor'])
    kernel=sorted((root/'boot').glob('vmlinuz-*'))[-1]
    initrd=root/'boot'/kernel.name.replace('vmlinuz-','initrd.img-')
    run(['sudo','-n','cp',str(kernel),str(D/'i386-vmlinuz')]);run(['sudo','-n','cp',str(initrd),str(D/'i386-initrd')])
    run(['truncate','-s','16G',str(D/'i386.raw')])
    run(['sudo','-n','mkfs.ext4','-q','-F','-d',str(root),str(D/'i386.raw')])
def start(a,foreground=False):
    serial_log=D/f'{a}-console.log'
    if serial_log.exists(): shutil.copy(serial_log,D/f'{a}-console-{int(time.time())}.log')
    common=['-m','4096','-smp','1' if a=='arm64' else '4','-display','none','-serial',f'file:{D}/{a}-console.log','-monitor','none','-netdev',f'user,id=net0,ipv6=off,hostfwd=tcp:127.0.0.1:{PORT[a]}-:22','-device','virtio-net-pci,netdev=net0','-daemonize','-pidfile',str(D/f'{a}.pid')]
    if foreground: common.remove('-daemonize')
    if a=='arm64':
        if not (D/'arm64-vars.fd').exists(): shutil.copy('/usr/share/AAVMF/AAVMF_VARS.fd',D/'arm64-vars.fd')
        cmd=['qemu-system-aarch64','-accel','tcg,thread=single','-machine','virt','-cpu','cortex-a72','-drive','if=pflash,format=raw,readonly=on,file=/usr/share/AAVMF/AAVMF_CODE.fd','-drive',f'if=pflash,format=raw,file={D}/arm64-vars.fd']
    elif a=='amd64': cmd=['qemu-system-x86_64','-enable-kvm','-cpu','host']
    else:
        cmd=['qemu-system-i386','-enable-kvm','-cpu','host','-kernel',str(D/'i386-vmlinuz'),'-initrd',str(D/'i386-initrd'),'-append','root=/dev/vda rw console=ttyS0 net.ifnames=0']
    disk=D/f'{a}.qcow2'
    if a=='i386': disk=D/'i386.raw'
    cmd+=['-drive',f'file={disk},format={"raw" if a=="i386" else "qcow2"},if=virtio']
    if a!='i386': cmd+=['-drive',f'file={D}/{a}-seed.iso,format=raw,if=virtio']
    cmd+=common
    (D/f'{a}-command.json').write_text(json.dumps(cmd,indent=2))
    if a!='arm64': cmd=['sg','kvm','-c',shlex.join(cmd)]
    run(cmd)
if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--foreground',action='store_true',help='keep QEMU attached to start (required inside host-job services)')
    p.add_argument('action',choices=['prepare','start','ssh','stop','status']);p.add_argument('arch',choices=PORT);p.add_argument('command',nargs=argparse.REMAINDER);args=p.parse_args()
    if args.foreground and args.action!='start': p.error('--foreground applies only to start')
    if args.action=='status':
        pid=D/f'{args.arch}.pid'
        running=pid.exists() and pathlib.Path('/proc/'+pid.read_text().strip()).exists()
        print(json.dumps({'arch':args.arch,'running':running,'assets':str(D)}))
        raise SystemExit(0 if running else 1)
    if args.action=='prepare': prepare(args.arch)
    elif args.action=='start': start(args.arch,args.foreground)
    elif args.action=='stop': os.kill(int((D/f'{args.arch}.pid').read_text()),signal.SIGTERM)
    else: raise SystemExit(subprocess.run(sshcmd(args.arch)+args.command).returncode)
