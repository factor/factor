#!/usr/bin/env python3
import os
"""Prepare and boot release RISC-V BSD guests. Factor validation uses separate stage evidence."""
import argparse, pathlib, subprocess, time, socket, os

DEFAULT = pathlib.Path(os.path.join(os.environ.get('FACTOR_QEMU_MATRIX_DIR','/home/sheeple/factor/work/qemu-matrix'),'riscv-bsd'))
PORTS = {'freebsd':22700, 'openbsd':22701, 'netbsd':22702}

def command(system, assets, install=False):
    p = pathlib.Path(assets)
    cmd = ['qemu-system-riscv64','-machine','virt','-m','2048','-smp','1','-display','none',
           '-monitor',f'unix:{p}/{system}.monitor,server=on,wait=off',
           '-chardev',f'socket,id=console,path={p}/{system}.sock,server=on,wait=off,logfile={p}/{system}-boot.log', '-serial','chardev:console',
           '-netdev',f'user,id=net,hostfwd=tcp:127.0.0.1:{PORTS[system]}-:22',
           '-device','virtio-net-device,netdev=net','-device','virtio-rng-device',
           '-pidfile',str(p/f'{system}.pid'),'-daemonize']
    if system == 'netbsd':
        cmd += ['-kernel',str(p/'netbsd-kernel'),'-append','root=dk1']
        disk, fmt = p/'netbsd.img', 'raw'
    else:
        cmd += ['-kernel','/usr/lib/u-boot/qemu-riscv64_smode/uboot.elf']
        disk, fmt = p/f'{system}.qcow2', 'qcow2'
    cmd += ['-drive',f'if=none,file={disk},format={fmt},id=root', '-device','virtio-blk-device,drive=root']
    if install:
        if system != 'openbsd': raise ValueError('Only OpenBSD uses installation media')
        cmd += ['-drive',f'if=none,file={p}/install79.img,format=raw,id=install',
                '-device','virtio-blk-device,drive=install']
    return cmd

class Console:
    def __init__(self, path, log):
        self.socket=socket.socket(socket.AF_UNIX); self.socket.connect(str(path));self.socket.settimeout(1)
        self.log=open(log,'a'); self.buffer=''
    def expect(self, needle, timeout=600):
        import re
        deadline=time.monotonic()+timeout
        while time.monotonic()<deadline:
            m=re.search(needle,self.buffer)
            if m:self.buffer=self.buffer[m.end():];return
            try:b=self.socket.recv(65536)
            except socket.timeout:continue
            if not b:raise EOFError('QEMU serial disconnected')
            t=b.decode(errors='replace'); self.log.write(t);self.log.flush();self.buffer+=t
        raise TimeoutError(f'Waiting for {needle}: {self.buffer[-2000:]}')
    def send(self, line):self.socket.sendall((line+'\r').encode())
    def shell(self, line):
        self.send(line);self.expect(r'[#] ')

def provision(system, p):
    c=Console(p/f'{system}.sock',p/f'{system}-console.log')
    c.expect('login:');c.send('root');c.expect(r'[#] ')
    key=pathlib.Path.home().joinpath('.ssh/id_ed25519.pub').read_text().strip()
    for line in ['mkdir -p /root/.ssh',f"echo '{key}' > /root/.ssh/authorized_keys",'chmod 700 /root/.ssh; chmod 600 /root/.ssh/authorized_keys','echo PermitRootLogin prohibit-password >> /etc/ssh/sshd_config']:
        c.shell(line)
    if system=='freebsd':
        c.shell('echo sshd_enable=YES >> /etc/rc.conf');c.shell('ssh-keygen -A; service sshd restart')
    elif system=='netbsd':
        c.shell('echo dhcpcd=YES >> /etc/rc.conf; echo sshd=YES >> /etc/rc.conf')
        c.shell('dhcpcd vioif0');c.shell('/etc/rc.d/sshd restart')
    c.shell('uname -a; cc --version; c++ --version')

def install_openbsd(p):
    c=Console(p/'openbsd.sock',p/'openbsd-install.log');c.expect(r'\(I\)nstall.*\(S\)hell');c.send('S');c.expect('# ')
    conf='''System hostname = openbsd-riscv64
    Which network interface do you wish to configure = vio0
    IPv4 address for vio0 = dhcp
    IPv6 address for vio0 = none
    Which network interface do you wish to configure = done
    Password for root = factor-qemu
    Password for root = factor-qemu
    Start sshd(8) by default = yes
    Do you expect to run the X Window System = no
    Change the default console to com0 = yes
    Which speed should com0 use = 115200
    Setup a user = no
    Allow root ssh login = yes
    What timezone are you in = UTC
    Which disk is the root disk = sd0
    Use (W)hole disk MBR, whole disk (G)PT or (E)dit = gpt
    Use (A)uto layout, (E)dit auto layout, or create (C)ustom layout = A
    Location of sets = disk
    Is the disk partition already mounted = no
    Which disk contains the install media = sd1
    Which disk partition has the install media = a
    Pathname to the sets = 7.9/riscv64
    Set name(s) = -x* -game* -man*
    Directory does not contain SHA256.sig. Continue without verification = yes
    Continue anyway = yes
    Location of sets = done
    '''
    conf='\n'.join(line.lstrip() for line in conf.splitlines())+'\n'
    c.send("cat > /tmp/install.conf <<'EOF'\n"+conf+'EOF');c.expect('# ');c.send('/install -a -f /tmp/install.conf');c.expect('CONGRATULATIONS',1800);c.expect('# ')
    key=pathlib.Path.home().joinpath('.ssh/id_ed25519.pub').read_text().strip()
    c.shell(f"mkdir -p /mnt/root/.ssh; echo '{key}' > /mnt/root/.ssh/authorized_keys; chmod 700 /mnt/root/.ssh; chmod 600 /mnt/root/.ssh/authorized_keys")
    c.shell('echo "PermitRootLogin prohibit-password" >> /mnt/etc/ssh/sshd_config')
    c.send('halt -p')
    try: c.expect(r'The operating system has halted|halted',180)
    except EOFError: pass

def smoke(system,p):
    import json
    code='#include <iostream>\nint main(){std::cout << 42 << std::endl;}\n'
    import shlex
    line='uname -a; c++ --version; printf %s '+shlex.quote(code)+' > /root/native.cc; c++ /root/native.cc -o /root/native && /root/native'
    r=subprocess.run(['ssh','-o','BatchMode=yes','-o','StrictHostKeyChecking=no','-p',str(PORTS[system]),'root@127.0.0.1',line],text=True,capture_output=True,timeout=600)
    (p/f'{system}-native.log').write_text(r.stdout+r.stderr)
    print(r.stdout,end='');print(r.stderr,end='')
    r.check_returncode()

if __name__=='__main__':
    a=argparse.ArgumentParser(description=__doc__);a.add_argument('system',choices=PORTS);a.add_argument('action',choices=['start','provision','command','install','smoke','status']);a.add_argument('--assets',type=pathlib.Path,default=DEFAULT);a.add_argument('--install',action='store_true');args=a.parse_args()
    if args.action=='status':
        import json
        pid=args.assets/f'{args.system}.pid';running=pid.exists() and pathlib.Path('/proc/'+pid.read_text().strip()).exists()
        print(json.dumps({'os':args.system,'running':running,'assets':str(args.assets)}));raise SystemExit(0 if running else 1)
    if args.action=='start':subprocess.run(command(args.system,args.assets,args.install),check=True)
    elif args.action=='install':
        if args.system != 'openbsd': raise ValueError('Only OpenBSD needs install')
        install_openbsd(args.assets)
    elif args.action=='smoke':
        smoke(args.system,args.assets)
    elif args.action=='provision':provision(args.system,args.assets)
    else:
        import shlex
        print(shlex.join(command(args.system,args.assets,args.install)))
