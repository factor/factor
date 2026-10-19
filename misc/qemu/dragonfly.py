#!/usr/bin/env python3
import os
"""DragonFlyBSD 6.4.2 x64 QEMU guest; x86/ARM targets unavailable upstream."""
import argparse, pathlib, subprocess, json, os, hashlib, socket, time
P=argparse.ArgumentParser(description=__doc__)
P.add_argument('action',choices=['fetch','start','provision','ssh','status','stop'])
P.add_argument('arch',choices=['amd64','x64'])
P.add_argument('command',nargs='*')
P.add_argument('--assets',default=os.environ.get('FACTOR_DRAGONFLY_ASSETS',os.path.join(os.environ.get('FACTOR_QEMU_MATRIX_DIR',str(pathlib.Path(__file__).resolve().parents[2]/'work/qemu-matrix')),'dragonfly')))
a=P.parse_args();d=pathlib.Path(a.assets);d.mkdir(parents=True,exist_ok=True)
def run(args):return subprocess.run(args,check=True)
if a.action=='fetch':
 run(['curl','-fL','https://avalon.dragonflybsd.org/iso-images/dfly-x86_64-6.4.2_REL.img.bz2','-o',str(d/'dfly.img.bz2')])
 with (d/'dfly.img.bz2').open('rb') as f:
  checksum = hashlib.file_digest(f, 'md5').hexdigest()
 if checksum != 'd321c363be7653525049c501ecf16e37':raise SystemExit('DragonFly release image checksum mismatch')
 run(['bunzip2','-k',str(d/'dfly.img.bz2')])
elif a.action=='start':
 if not (d/'work.img').exists():run(['qemu-img','create','-f','raw',str(d/'work.img'),'20G'])
 cmd=['qemu-system-x86_64','-enable-kvm','-cpu','host','-m','8192','-smp','4','-drive',f'file={d}/dfly.img,format=raw','-drive',f'file={d}/work.img,format=raw','-nic','user,model=e1000,hostfwd=tcp:127.0.0.1:22500-:22','-display','vnc=127.0.0.1:50','-monitor',f'unix:{d}/monitor.sock,server=on,wait=off','-serial',f'file:{d}/serial.log','-pidfile',str(d/'qemu.pid'),'-daemonize']
 import shlex
 run(['sg','kvm','-c',shlex.join(cmd)])
elif a.action=='provision':
 if (d/'provisioned').exists():raise SystemExit('Guest already provisioned')
 if not (d/'id_ed25519').exists():run(['ssh-keygen','-q','-t','ed25519','-N','','-f',str(d/'id_ed25519')])
 # Release live-image root login is passwordless on the VGA console.
 time.sleep(75)
 monitor=socket.socket(socket.AF_UNIX);monitor.connect(str(d/'monitor.sock'));monitor.recv(65536)
 def type_text(value):
  keys={' ':'spc','\n':'ret','/':'slash','.':'dot','-':'minus','_':'shift-minus',':':'shift-semicolon','=':'equal','"':'shift-apostrophe','>':'shift-dot',';':'semicolon','+':'shift-equal','@':'shift-2',"'":'apostrophe'}
  for char in value:
   key=keys.get(char,char)
   if char.isupper():key='shift-'+char.lower()
   monitor.sendall(('sendkey '+key+'\n').encode());time.sleep(.06);monitor.recv(65536)
 type_text('root\n');time.sleep(2)
 pub=(d/'id_ed25519.pub').read_text().strip()
 type_text('ifconfig em0 inet 10.0.2.15 netmask 255.255.255.0\nroute add default 10.0.2.2\necho nameserver 10.0.2.3 > /etc/resolv.conf\nmkdir -p /root/.ssh\necho "'+pub+'" > /root/.ssh/authorized_keys\nchmod 700 /root/.ssh\nchmod 600 /root/.ssh/authorized_keys\necho PermitRootLogin yes >> /etc/ssh/sshd_config\necho sshd_enable=YES >> /etc/rc.conf\necho \'ifconfig_em0="inet 10.0.2.15 netmask 255.255.255.0"\' >> /etc/rc.conf\necho defaultrouter="10.0.2.2" >> /etc/rc.conf\nservice sshd onestart\n')
 time.sleep(5)
 # The secondary disk was created by the start action for Factor build assets.
 run(['ssh','-i',str(d/'id_ed25519'),'-p','22500','-o','StrictHostKeyChecking=no','-o','UserKnownHostsFile=/dev/null','root@127.0.0.1','newfs /dev/ad1; mkdir /work; mount /dev/ad1 /work; echo /dev/ad1 /work ufs rw 1 1 >> /etc/fstab; pkg install -y gmake bash gcc14; sync'])
 (d/'provisioned').write_text('DragonFlyBSD 6.4.2 root SSH + /work initialized\n')
elif a.action=='ssh':
 run(['ssh','-i',str(d/'id_ed25519'),'-p','22500','-o','StrictHostKeyChecking=no','-o','UserKnownHostsFile=/dev/null','root@127.0.0.1',*a.command])
elif a.action=='stop':os.kill(int((d/'qemu.pid').read_text()),15)
else:
 try:os.kill(int((d/'qemu.pid').read_text()),0);state='running'
 except (OSError,ValueError):state='stopped'
 print(json.dumps({'os':'dragonfly','arch':'x64','status':state,'ssh_port':22500,'assets':str(d)}))
