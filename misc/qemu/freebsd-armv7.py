#!/usr/bin/env python3
"""Stage or boot the official FreeBSD14.5 ARMv7 GENERICSD native foundation."""
import argparse, hashlib, json, lzma, pathlib, shutil, subprocess, urllib.request
ROOT = pathlib.Path(__file__).resolve().parents[2]
NAME = 'FreeBSD-14.5-RELEASE-arm-armv7-GENERICSD.img.xz'
URL = 'https://download.freebsd.org/releases/ISO-IMAGES/14.5/'
SHA256 = '8e1f0b3230cb70f9668c4231a6b47332bc54f69f0b4328eca11621dafb396949'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('action', choices=['plan', 'prepare', 'start'])
p.add_argument('--assets', type=pathlib.Path, default=ROOT/'work/qemu-matrix/freebsd/armv7')
p.add_argument('--firmware', type=pathlib.Path, default=ROOT/'work/qemu-matrix/new-bsd/arm32-netbsd11/firmware/usr/share/AAVMF/AAVMF32_CODE.fd')
a = p.parse_args(); d = a.assets.resolve(); firmware = a.firmware.resolve()
disk = d/'guest.qcow2'; pidfile = d/'qemu.pid'
command = ['qemu-system-arm', '-machine', 'virt,highmem=off,gic-version=2',
           '-cpu', 'cortex-a15', '-m', '1024', '-smp', '2',
           '-global', 'virtio-mmio.force-legacy=true', '-bios', str(firmware),
           '-display', 'none', '-monitor', f'unix:{d}/monitor.sock,server=on,wait=off',
           '-chardev', f'socket,id=serial,path={d}/serial.sock,server=on,wait=off,logfile={d}/console.log',
           '-serial', 'chardev:serial', '-drive', f'file={disk},format=qcow2,if=virtio',
           '-netdev', 'user,id=n,ipv6=off,hostfwd=tcp:127.0.0.1:22203-:22',
           '-device', 'virtio-net-device,netdev=n,mrg_rxbuf=off',
           '-daemonize', '-pidfile', str(pidfile)]
if a.action == 'plan':
    print(json.dumps({'release': '14.5-RELEASE', 'architecture': 'armv7',
                      'image_url': URL+NAME, 'compressed_bytes': 416560816,
                      'raw_bytes': 5368709120, 'sha256': SHA256,
                      'boot_status': 'unverified', 'command': command}, indent=2))
    raise SystemExit(0)
d.mkdir(parents=True, exist_ok=True)
if a.action == 'prepare':
    if shutil.disk_usage(d).free < 12*1024**3:
        raise SystemExit('Need at least12GiB free before provisioning; existing guests remain untouched')
    archive = d/NAME
    if not archive.exists():
        partial = d/(NAME+'.partial'); urllib.request.urlretrieve(URL+NAME, partial); partial.rename(archive)
    with archive.open('rb') as f:
        if hashlib.file_digest(f, 'sha256').hexdigest() != SHA256:
            raise SystemExit('Official image SHA256 mismatch')
    raw = d/'release.img'
    if not raw.exists():
        temporary = d/'release.img.partial'
        with lzma.open(archive) as src, temporary.open('wb') as dst:
            while chunk := src.read(1024*1024):
                if chunk.count(0) == len(chunk): dst.seek(len(chunk), 1)
                else: dst.write(chunk)
            dst.truncate()
        temporary.rename(raw)
    if not disk.exists():
        subprocess.run(['qemu-img', 'create', '-f', 'qcow2', '-F', 'raw', '-b', str(raw), str(disk), '12G'], check=True)
    raise SystemExit(0)
if pidfile.exists() and pathlib.Path('/proc/'+pidfile.read_text().strip()).exists():
    raise SystemExit('Guest PID alive; refusing duplicate start')
if not disk.is_file() or not firmware.is_file():
    raise SystemExit('Run prepare with adequate storage and provide AAVMF32 firmware first')
(d/'command.json').write_text(json.dumps(command, indent=2)+'\n')
subprocess.run(command, check=True)
