#!/usr/bin/env python3
"""Start the installed OpenBSD 7.9 ARMv7 native foundation (not a Factor gate)."""
import argparse, pathlib, subprocess, json
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--assets',type=pathlib.Path,required=True,help='new-bsd directory')
a=p.parse_args();d=a.assets.resolve()/'armv7-openbsd79'
pidfile=d/'qemu.pid'
if pidfile.exists():
 pid=int(pidfile.read_text().strip())
 if (pathlib.Path('/proc')/str(pid)).exists():raise SystemExit('PID is alive; refusing to replace any running guest')
firmware=a.assets.resolve()/'arm32-netbsd11/firmware/usr/share/AAVMF/AAVMF32_CODE.fd'
manifest=d/'foundation.json'
disk=d/(json.loads(manifest.read_text()).get('disk','install.qcow2') if manifest.exists() else 'install.qcow2')
if not disk.is_file() or not firmware.is_file():raise SystemExit('Installed disk or AAVMF32 firmware missing')
cmd=['qemu-system-arm','-M','virt','-cpu','cortex-a15','-m','1024','-global','virtio-mmio.force-legacy=true','-display','none','-monitor',f'unix:{d}/monitor.sock,server=on,wait=off','-chardev',f'socket,id=serial,path={d}/serial.sock,server=on,wait=off,logfile={d}/replay-console.log','-serial','chardev:serial','-bios',str(firmware),'-drive',f'file={disk},format=qcow2,if=virtio','-netdev','user,id=n,ipv6=off,hostfwd=tcp:127.0.0.1:23020-:22','-device','virtio-net-device,netdev=n,mrg_rxbuf=off','-daemonize','-pidfile',str(pidfile)]
(d/'replay-command.json').write_text(json.dumps(cmd,indent=2)+'\n')
subprocess.run(cmd,check=True)
print('Started installed OpenBSD ARMv7, SSH23020; native foundation only.')
