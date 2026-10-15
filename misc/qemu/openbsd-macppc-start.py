#!/usr/bin/env python3
"""Start the patched OpenBSD macppc RAMDISK/chroot foundation, not a Factor gate.

Launch this script through misc/qemu/host-job.py --profile vm. The guest assets
must contain the authenticated official CD, installed disk, fixture ISO, and
private QEMU with the five v3 patches pinned in provenance/qemu-build.json.
GENERIC currently fails its original Retguard check; PCI NIC attach also fails.
This deliberately reproduces the measured no-NIC RAMDISK/chroot route.
"""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import socket

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--assets', type=Path, required=True, help='new-bsd directory')
parser.add_argument('--fixture', default='fixture-v4.iso', help='immutable fixture ISO name')
parser.add_argument('--print-command', action='store_true')
parser.add_argument('--serial-ssh', action='store_true', help='add a raw second UART for native sshd -i; not a TCP route')
args = parser.parse_args()
directory = args.assets.resolve() / 'macppc-openbsd79'
qemu = directory / 'qemu-build/qemu-system-ppc'
cd = directory / 'cd79.iso'
disk = directory / 'disk.qcow2'
fixture = directory / args.fixture
for path in (qemu, cd, disk, fixture):
    if not path.is_file():
        raise SystemExit(f'Missing guest asset: {path}')
pins = json.loads((directory / 'provenance/qemu-build.json').read_text())
if hashlib.sha256(qemu.read_bytes()).hexdigest() != pins['binary_sha256']:
    raise SystemExit('Private patched QEMU does not match recorded binary hash')
if hashlib.sha256(cd.read_bytes()).hexdigest() != '227fef3d5089d56ce8376d8bfa28181ce5b19f0eceef0a6d82d58d8e52832b24':
    raise SystemExit('Official cd79.iso does not match authenticated installer hash')
monitor = directory / 'monitor.sock'
serial = directory / 'foundation-serial.sock'
cmd = [str(qemu), '-M', 'mac99,via=cuda,graphics=off,usb=off', '-cpu', '7400',
       '-accel', 'tcg,thread=single', '-smp', '1', '-m', '2g', '-nic', 'none',
       '-device', 'VGA', '-global', 'cuda.x-sr-delay-ns=0',
       '-prom-env', 'input-device=ttya', '-prom-env', 'output-device=ttya',
       '-drive', f'file={disk},format=qcow2,if=ide,index=0',
       '-cdrom', str(cd), '-drive', f'file={fixture},format=raw,if=ide,index=3,media=cdrom',
       '-boot', 'd', '-no-reboot', '-display', 'none',
       '-chardev', f'socket,id=serial,path={serial},server=on,wait=off,logfile={directory}/foundation-console.log',
       '-serial', 'chardev:serial', '-monitor', f'unix:{monitor},server=on,wait=off']
if args.serial_ssh:
    cmd += ['-chardev', f'socket,id=sshserial,path={directory}/ssh-serial.sock,server=on,wait=off',
            '-serial', 'chardev:sshserial']
if args.print_command:
    print(json.dumps(cmd, indent=2))
    raise SystemExit(0)
lease = open(directory / 'foundation-guest.lock', 'a')
try:
    fcntl.flock(lease, fcntl.LOCK_EX | fcntl.LOCK_NB)
except BlockingIOError:
    raise SystemExit('Foundation guest lease is held by a live process')
probe = socket.socket(socket.AF_UNIX)
try:
    probe.connect(str(monitor))
except (FileNotFoundError, ConnectionRefusedError):
    pass
else:
    raise SystemExit('Guest monitor is live; refusing a duplicate disk writer')
finally:
    probe.close()
os.set_inheritable(lease.fileno(), True)
(directory / 'foundation-command.json').write_text(json.dumps(cmd, indent=2) + '\n')
os.execv(str(qemu), cmd)
