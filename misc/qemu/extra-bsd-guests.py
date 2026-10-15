#!/usr/bin/env python3
"""Replay installed native BSD foundations. These are not Factor VM gates.

The SPARC64 guest uses a RAMDISK kernel and installed chroot because GENERIC
faults early in QEMU. PPC guests use the verified release CD boot loader/kernel
and installed UFS root; this avoids firmware boot-block compatibility problems.
"""
import argparse, json, os, pathlib, subprocess, sys
import pexpect
ROOT = pathlib.Path(__file__).resolve().parents[2]
SPECS = {
 'sparc64-openbsd79': (23014, 'qemu-system-sparc64', ['-M','sun4u','-m','1024','-prom-env','input-device=ttya','-prom-env','output-device=ttya','-prom-env','boot-file=bsd.rd'], 'ide', None),
 'ppc32-freebsd145': (23016, 'qemu-system-ppc', ['-M','mac99,via=pmu','-m','1024','-smp','1'], 'ide', 'ada0s3'),
 'ppc64be-freebsd145': (23017, 'qemu-system-ppc64', ['-M','pseries','-cpu','POWER9','-m','1024','-smp','1','-vga','none'], 'virtio', 'vtbd0s2a'),
 'ppc64le-freebsd145': (23018, 'qemu-system-ppc64', ['-M','pseries','-cpu','POWER9','-m','1024','-smp','1','-vga','none'], 'virtio', 'vtbd0p2'),
}
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('action',choices=['start','configure','status','probe'])
p.add_argument('guest',choices=SPECS)
p.add_argument('--assets',type=pathlib.Path,default=pathlib.Path(os.environ.get('FACTOR_QEMU_MATRIX_DIR',str(ROOT/'work/qemu-matrix')))/'new-bsd')
p.add_argument('--key',type=pathlib.Path)
p.add_argument('--timeout',type=int,default=900)
a=p.parse_args();d=a.assets/a.guest
port,exe,board,interface,rootdev=SPECS[a.guest]
key=a.key or a.assets.parent/'linux/id_ed25519'
def owned_pid():
 f=d/'qemu.pid'
 if not f.exists():return None
 pid=int(f.read_text().strip());q=pathlib.Path('/proc')/str(pid)/'cmdline'
 if not q.exists():return None
 args=q.read_bytes().split(b'\0')
 if pathlib.Path(os.fsdecode(args[0])).name!=exe or not any(f'{port}-:22'.encode() in item for item in args):raise SystemExit('PID file belongs to another process')
 cwd=pathlib.Path('/proc')/str(pid)/'cwd'
 disks=[pathlib.Path(os.fsdecode(item).split(',',1)[0][5:]) for item in args if item.startswith(b'file=')]
 target=(d/'disk.qcow2').resolve()
 disk_matches=any((x if x.is_absolute() else cwd/x).resolve()==target for x in disks)
 if not disk_matches:
  # QEMU daemonize changes cwd after opening relative drive paths.
  for fd in (pathlib.Path('/proc')/str(pid)/'fd').iterdir():
   try:disk_matches=fd.resolve()==target
   except OSError:continue
   if disk_matches:break
 if not disk_matches:raise SystemExit('PID does not own this guest disk')
 return pid
if a.action=='status':
 print(json.dumps({'guest':a.guest,'pid':owned_pid(),'ssh_port':port,'factor_vm_validated':False}));sys.exit()
if a.action=='probe':
 sys.exit(subprocess.call([str(ROOT/'misc/qemu/bsd-native-foundation.sh'),str(port),str(key),str(d)]))
if a.action=='start':
 if owned_pid():raise SystemExit('Guest already running; start will not replace it')
 if not (d/'disk.qcow2').is_file():raise SystemExit('Missing installed disk.qcow2')
 cmd=[exe]+board+['-display','none','-monitor',f'unix:{d}/monitor.sock,server=on,wait=off','-chardev',f'socket,id=serial,path={d}/serial.sock,server=on,wait=off,logfile={d}/replay-console.log','-serial','chardev:serial','-drive',f'file={d}/disk.qcow2,format=qcow2,if={interface}']
 if rootdev:cmd+=['-cdrom',str(d/'disc1.iso'),'-boot','d']
 if rootdev and a.guest!='ppc32-freebsd145':cmd+=['-netdev',f'user,id=n,hostfwd=tcp:127.0.0.1:{port}-:22','-device','virtio-net-pci,netdev=n']
 else:cmd+=['-net','nic,model='+('sunhme' if not rootdev else 'rtl8139'),'-net',f'user,hostfwd=tcp:127.0.0.1:{port}-:22']
 cmd+=['-pidfile',str(d/'qemu.pid')]
 if a.guest=='ppc32-freebsd145':cmd[cmd.index('-display'):cmd.index('-display')+2]=['-nographic']
 else:cmd+=['-daemonize']
 (d/'replay-command.json').write_text(json.dumps(cmd,indent=2)+'\n')
 if a.guest=='ppc32-freebsd145':
  subprocess.Popen(cmd,stdin=subprocess.DEVNULL,stdout=subprocess.DEVNULL,stderr=open(d/'qemu-stderr.log','w'),start_new_session=True)
  import time
  for attempt in range(100):
   if owned_pid() and (d/'serial.sock').exists():break
   time.sleep(.05)
 else:subprocess.run(cmd,check=True)
if not owned_pid():raise SystemExit('Guest is not running')
c=pexpect.spawn('nc',['-U',str(d/'serial.sock')],encoding='utf-8',codec_errors='replace',timeout=a.timeout)
c.logfile=open(d/'replay-setup.log','w',buffering=1)
if rootdev:
 c.expect('Hit.*Enter.*boot immediately');c.sendline(' ');c.expect('OK')
 for setting in (['hint.ata.0.mode=PIO4','hint.ata.1.mode=PIO4'] if a.guest=='ppc32-freebsd145' else [])+[f'vfs.root.mountfrom=ufs:/dev/{rootdev}']:
  c.sendline('set '+setting);c.expect('OK')
 c.sendline('boot');c.expect(['login:','mountroot>'])
 if c.after=='mountroot>':raise SystemExit('Installed root failed to mount')
else:
 c.expect(r'\(I\)nstall.*\(S\)hell');c.sendline('s');c.expect('#')
 commands=['cd /dev; sh MAKEDEV wd0; cd /','fsck -p /dev/wd0a','fsck -p /dev/wd0d','fsck -p /dev/wd0e','mount -o wxallowed /dev/wd0a /mnt','mount /dev/wd0d /mnt/usr','mount /dev/wd0e /mnt/home','ifconfig hme0 inet autoconf','chroot /mnt /usr/sbin/sshd']
 for command in commands:c.sendline(command);c.expect('#')
print(json.dumps({'guest':a.guest,'ssh_port':port,'kernel_mode':'release-CD-with-installed-root' if rootdev else 'RAMDISK-with-installed-chroot','factor_vm_validated':False}))
