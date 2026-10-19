#!/usr/bin/env python3
import os
"""Provision isolated OpenBSD 7.9 QEMU guests using the stock installer."""
import argparse, pathlib, pexpect, subprocess, time
p=argparse.ArgumentParser();p.add_argument('arch',choices=['amd64','i386','arm64']);p.add_argument('--assets',default=os.path.join(os.environ.get('FACTOR_QEMU_MATRIX_DIR','/home/sheeple/factor/work/qemu-matrix'),'openbsd'));p.add_argument('--port',type=int,default=22400);a=p.parse_args()
d=pathlib.Path(a.assets);disk=d/(a.arch+'.qcow2');iso=d/(a.arch+'-install79.iso')
if not disk.exists():subprocess.run(['qemu-img','create','-f','qcow2',str(disk),'16G'],check=True)
cmd=['qemu-system-'+{'amd64':'x86_64','i386':'i386','arm64':'aarch64'}[a.arch],'-m','2048','-smp','1','-nographic','-no-reboot','-drive',f'file={disk},format=qcow2,if=virtio','-cdrom',str(iso),'-boot','d','-netdev',f'user,id=n,hostfwd=tcp:127.0.0.1:{a.port}-:22','-device','virtio-net-pci,netdev=n']
if a.arch=='arm64':
 cmd[cmd.index('-cdrom'):cmd.index('-cdrom')+2]=['-drive',f'file={iso},media=cdrom,if=none,id=cd','-device','virtio-scsi-pci,id=scsi','-device','scsi-cd,drive=cd,bus=scsi.0']
 cmd += ['-machine','virt','-cpu','cortex-a72','-bios','/usr/share/AAVMF/AAVMF_CODE.fd']
elif a.arch=='i386':cmd += ['-accel','tcg','-cpu','max']
else:cmd=['sg','kvm','-c', ' '.join(cmd+['-accel','kvm','-cpu','host'])]
c=pexpect.spawn(cmd[0],cmd[1:],encoding='utf-8',timeout=300);c.logfile=open(d/(a.arch+'-install.log'),'w',buffering=1)
if a.arch!='arm64':
 c.expect('boot>');c.sendline('set tty com0');c.expect('boot>');c.sendline('boot')
c.expect(r'\(I\)nstall.*\(S\)hell');c.sendline('s');c.expect('#')
c.sendline('ifconfig vio0 inet autoconf; sleep 3');c.expect('#')
conf='''System hostname = factor-{arch}
Password for root = factor
Network interfaces = vio0
IPv4 address for vio0 = dhcp
IPv6 address for vio0 = none
Setup a user = no
Allow root ssh login = yes
Do you expect to run the X Window System = no
Which disk is the root disk = sd0
Use (W)hole disk MBR, whole disk (G)PT or (E)dit = whole
Use (A)uto layout, (E)dit auto layout, or create (C)ustom layout = auto
Location of sets = cd0
Pathname to the sets = {ver}/{arch}
Set name(s) = -x* -game* -man*
Directory does not contain SHA256.sig. Continue without verification = yes
Continue anyway = yes
Location of sets = done
What timezone are you in = UTC
'''.format(arch=a.arch,ver='7.9')
c.sendline("cat > /tmp/install.conf <<'EOF'\n"+conf+'EOF');c.expect('#');c.sendline('/install -a -f /tmp/install.conf')
c.expect([r'CONGRATULATIONS',r'Question has no answer',r'Are you \*SURE\*'],timeout=1800)
if 'Question' in c.after:
 print('INSTALL QUESTION FAILURE',c.before[-1000:]);c.interact();raise SystemExit(1)
c.expect('#');c.sendline(('echo \"set tty com0\" > /mnt/etc/boot.conf; ' if a.arch != 'arm64' else '') + 'halt -p')
c.expect([pexpect.EOF, 'Please press any key to reboot'],timeout=300)
c.close(force=True)
