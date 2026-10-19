#!/usr/bin/env python3
import os
"""Run the NetBSD 11 matrix guests; disks are local ignored work artifacts."""
import argparse,json,os,pathlib,subprocess,sys
ROOT=pathlib.Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('action',choices=['start','stop','status','ssh','mark'])
p.add_argument('arch',choices=['amd64','i386','aarch64'])
p.add_argument('command',nargs='?',default='uname -a')
p.add_argument('--assets',type=pathlib.Path,default=pathlib.Path(os.environ.get('FACTOR_QEMU_MATRIX_DIR',str(ROOT/'work/qemu-matrix')))/'netbsd')
p.add_argument('--identity',type=pathlib.Path,default=pathlib.Path.home()/'.ssh/id_ed25519')
a=p.parse_args(); assets=a.assets.resolve(); port={'amd64':22300,'i386':22301,'aarch64':22302}[a.arch]
pidfile=assets/(a.arch+'.pid')
ssh=['ssh','-i',str(a.identity),'-o','IdentitiesOnly=yes','-o','StrictHostKeyChecking=no','-o','UserKnownHostsFile=/dev/null','-p',str(port),'root@127.0.0.1']
if a.action=='ssh':sys.exit(subprocess.call(ssh+[a.command]))
if a.action=='mark':
 import shlex
 sys.exit(subprocess.call(ssh+['/usr/sbin/paxctl +m '+shlex.quote(a.command)]))
if a.action=='stop':
 if pidfile.exists():
  try:os.kill(int(pidfile.read_text()),15)
  except ProcessLookupError:pass
 sys.exit(0)
if a.action=='status':
 running=pidfile.exists() and pathlib.Path('/proc/'+pidfile.read_text().strip()).exists()
 print(json.dumps({'arch':a.arch,'running':running,'ssh_port':port,'assets':str(assets)}));sys.exit(0 if running else 1)
if not assets.exists():p.error('Download and provision NetBSD images first; assets directory is absent.')
q=['qemu-system-'+('aarch64' if a.arch=='aarch64' else 'x86_64' if a.arch=='amd64' else 'i386'),'-m','2048','-smp','2','-display','none','-serial','file:'+str(assets/(a.arch+'.console.log')),'-monitor','unix:'+str(assets/(a.arch+'.monitor'))+',server=on,wait=off','-pidfile',str(pidfile),'-daemonize']
net='user,id=n,hostfwd=tcp:127.0.0.1:'+str(port)+'-:22'
if a.arch=='aarch64':
 q+=['-M','virt','-cpu','cortex-a57','-bios','/usr/share/qemu-efi-aarch64/QEMU_EFI.fd','-drive','if=none,file='+str(assets/'arm64.img')+',format=raw,id=d','-device','virtio-blk-device,drive=d','-device','virtio-rng-pci','-netdev',net,'-device','virtio-net-device,netdev=n']
else:
 q+=['-accel','kvm','-drive','file='+str(assets/a.arch/'installed.img')+',format=raw','-netdev',net,'-device','e1000,netdev=n']
# Start with fresh kvm group credentials when the current shell predates setup.
if a.arch!='aarch64':
 import shlex
 q=['sg','kvm','-c',shlex.join(q)]
sys.exit(subprocess.call(q))
