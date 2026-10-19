#!/usr/bin/env python3
"""Prepare pinned stock NixOS/Guix guests for the shared validation harness."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile
import time


IMAGES = json.loads(Path(__file__).with_name('images.json').read_text())


def run(argv, **kwargs):
    return subprocess.run(argv, check=True, **kwargs)


def sha256(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def extract_guix(image, destination, spec):
    # Use a read-only NBD export and mount. The harness creates its own COW
    # for each run; preparation never writes the downloaded release image.
    run(['sudo', '-n', 'modprobe', 'nbd', 'max_part=8'])
    devices = [p for p in sorted(Path('/sys/block').glob('nbd*'))
               if not (p / 'pid').exists()]
    if not devices:
        raise RuntimeError('no unused NBD device is available')
    device = '/dev/' + devices[0].name
    connected = mounted = False
    with tempfile.TemporaryDirectory(prefix='factor-guix-inspect-') as temporary:
        try:
            run(['sudo', '-n', 'qemu-nbd', '--read-only', '--connect=' + device, str(image)])
            connected = True
            partition = device + 'p2'
            for _ in range(100):
                if Path(partition).exists():
                    break
                time.sleep(.1)
            run(['sudo', '-n', 'mount', '-o', 'ro,noload', partition, temporary])
            mounted = True
            for name in ('kernel', 'initrd'):
                shutil.copyfile(Path(temporary) / spec[name].lstrip('/'), destination / name)
        finally:
            try:
                if mounted:
                    run(['sudo', '-n', 'umount', temporary])
            finally:
                if connected:
                    run(['sudo', '-n', 'qemu-nbd', '--disconnect', device])


def extract_nixos(image, destination, spec):
    for name in ('kernel', 'initrd'):
        with (destination / name).open('wb') as stream:
            run(['isoinfo', '-R', '-i', str(image), '-x', spec[name]], stdout=stream)


def prepare_guix_i686(image, destination, spec):
    """Prepare an ext4 root to avoid the release kernel's 32-bit zisofs bug."""
    stock_initrd = destination / 'initrd.stock'
    for name, output in (('kernel', destination / 'kernel'), ('initrd', stock_initrd)):
        with output.open('wb') as stream:
            run(['isoinfo', '-R', '-i', str(image), '-x', spec[name]], stdout=stream)
        if sha256(output) != spec[name + '_sha256']:
            raise RuntimeError(name + ' checksum mismatch')

    rootfs = destination / 'rootfs.raw'
    temporary_rootfs = destination / 'rootfs.raw.part'
    temporary_rootfs.unlink(missing_ok=True)
    run(['qemu-img', 'create', '-q', '-f', 'raw', str(temporary_rootfs), '8G'])
    run(['mkfs.ext4', '-q', '-F', '-L', 'GUIX_I686', str(temporary_rootfs)])
    with tempfile.TemporaryDirectory(prefix='factor-guix-i686-root-') as mount:
        mounted = False
        try:
            run(['sudo', '-n', 'mount', '-o', 'loop', str(temporary_rootfs), mount])
            mounted = True
            # Run extraction as root so the ISO's numeric ownership is retained.
            run(['sudo', '-n', 'bsdtar', '-xf', str(image), '-C', mount])
            run(['sync'])
        finally:
            if mounted:
                run(['sudo', '-n', 'umount', mount])
    temporary_rootfs.replace(rootfs)

    with tempfile.TemporaryDirectory(prefix='factor-guix-i686-initrd-') as tree:
        tree = Path(tree)
        command = f'zcat {shlex.quote(str(stock_initrd))} | cpio -id --quiet'
        run(['bash', '-o', 'pipefail', '-c', command], cwd=tree)
        init = tree / spec['init']
        data = init.read_bytes()
        replacements = (
            (b'((uuid iso9660 #vu8(49 57 55 48 48 49 48 49 49 57 49 49 51 51 56 51)) "/" "iso9660"',
             b'("/dev/vda" "/" "ext4"'),
            (b'"ext4" () #f #f #t #t preen', b'"ext4" () #f #f #f #t preen'),
            (b'#:volatile-root? (quote #t)', b'#:volatile-root? (quote #f)'),
        )
        for old, new in replacements:
            if data.count(old) != 1:
                raise RuntimeError('unexpected Guix i686 initrd layout: ' + repr(old))
            data = data.replace(old, new)
        init.chmod(init.stat().st_mode | 0o200)
        init.write_bytes(data)
        derived = destination / 'initrd'
        command = ('find . -print0 | cpio --null -o -H newc --quiet | '
                   'gzip -9 > ' + shlex.quote(str(derived)))
        run(['bash', '-o', 'pipefail', '-c', command], cwd=tree)
    return {'derived_initrd_sha256': sha256(destination / 'initrd'),
            'rootfs_sha256': sha256(rootfs)}


def ssh_setup():
    return '''#!/usr/bin/env bash
set -eu
mkdir -p /root/.ssh
cp /mnt/factor/id_ed25519.pub /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
if [ -d /nix/store ]; then
    systemctl start sshd
else
    sshd=$(printf '%s\\n' /gnu/store/*-openssh-*/sbin/sshd | head -1)
    sshbase=${sshd%/sbin/sshd}
    id sshd >/dev/null 2>&1 || /run/current-system/profile/sbin/useradd --system --no-create-home --home-dir /var/empty sshd
    mkdir -p /var/empty /var/run/sshd
    if ! [ -e /root/host_key ]; then
        "$sshbase/bin/ssh-keygen" -q -t ed25519 -N '' -f /root/host_key
    fi
    "$sshd" -h /root/host_key -f /dev/null -o PermitRootLogin=prohibit-password -o PasswordAuthentication=no -o UsePAM=no -o PidFile=/root/sshd.pid
fi
printf 'FACTOR_SSH_READY\\n'
'''


def profile(root, target, spec, profile_name=None):
    distro, arch = target.split('-', 1)
    destination = root / target
    intel = arch in ('x86_64', 'i686')
    i686 = target == 'guix-i686'
    port = 35320 if i686 else (35220 if distro == 'guix' else 35222) + (0 if arch == 'x86_64' else 1)
    qemu_arch = 'i386' if i686 else arch
    argv = ['qemu-system-' + qemu_arch, '-m', '3072' if i686 else '6144',
            '-smp', '1' if i686 else '4',
            '-kernel', str(destination / 'kernel'), '-initrd', str(destination / 'initrd'),
            '-append', spec['append'], '-netdev',
            f'user,id=net,hostfwd=tcp:127.0.0.1:{port}-:22',
            '-device', 'virtio-net-pci,netdev=net',
            '-fsdev', f'local,id=share,path={root / "share"},security_model=none,readonly=on',
            '-device', 'virtio-9p-pci,fsdev=share,mount_tag=factor',
            '-device', 'virtio-gpu-pci', '-no-reboot']
    argv += (['-accel', 'kvm', '-cpu', 'qemu32' if i686 else 'host'] if intel else
             ['-machine', 'virt', '-accel', 'tcg,thread=multi', '-cpu', 'cortex-a72'])
    setup = 'mkdir -p /mnt/factor; mount -t 9p -o trans=virtio factor /mnt/factor; bash /mnt/factor/setup-ssh\r'
    steps = []
    if distro == 'nixos':
        steps = [{'expect': 'nixos@nixos:~', 'send':
                  'sudo bash -c ' + shlex.quote(setup.rstrip('\r')) + '\r'}]
    elif not i686:
        steps = [{'expect': 'gnu login:', 'send': 'root\r'},
                 {'expect': 'root@gnu ~#', 'send': setup}]
    if not i686:
        steps.append({'expect': 'FACTOR_SSH_READY', 'send': ''})
    drive = (destination / 'rootfs.raw' if i686 else
             root / 'downloads' / (target + ('.qcow2' if distro == 'guix' else '.iso')))
    guest = {
        'argv': argv,
        'drives': [{'file': str(drive),
                    'format': 'raw' if i686 or distro == 'nixos' else 'qcow2', 'options': 'if=virtio'}],
        'console_steps': steps, 'console_char_delay': .004,
        'display_args': ['-display', f'vnc=127.0.0.1:{port - 35200}'],
        # These live guests keep downloaded packages in a swap-backed tmpfs.
        # Drop unused test closures before systemd tries to deactivate swap.
        'shutdown': ('nix-store --gc; sync; poweroff' if distro == 'nixos' else
                     'sync; /run/current-system/profile/sbin/halt'),
    }
    if i686:
        guest.update({
            'vnc_server': '127.0.0.1::6020',
            'vnc_actions': [
                {'pause': 35}, {'key': 'ctrl-alt-f3'}, {'pause': 3},
                {'key': 'enter'}, {'pause': 2}, {'text': setup.rstrip('\r') + '\n'},
            ],
        })
    if distro == 'nixos':
        # The live image stores new packages in RAM. A second architecture's
        # GTK closure otherwise leaves too little memory for the native build.
        guest['scratch_drives'] = [{'size': '8G', 'options': 'if=virtio'}]
        store_size = '10G' if profile_name == 'nixos-x86-32' else '4G'
        guest['setup'] = (
            "if ! grep -q '^/dev/vdb ' /proc/swaps; then "
            'mkswap /dev/vdb; swapon /dev/vdb; fi; '
            f'mount -o remount,size={store_size} /nix/.rw-store')
    return {'guest': guest, 'transport': {'kind': 'ssh', 'argv': [
        'ssh', '-F', '/dev/null', '-i', str(root / 'id_ed25519'),
        '-o', 'IdentitiesOnly=yes', '-o', 'BatchMode=yes',
        '-o', 'StrictHostKeyChecking=no', '-o', 'UserKnownHostsFile=/dev/null',
        '-o', 'ConnectTimeout=20', '-p', str(port), 'root@127.0.0.1']}}


def prepare(root, target, profile_name=None):
    spec = IMAGES[target]
    destination = root / target
    destination.mkdir(parents=True, exist_ok=True)
    downloads = root / 'downloads'
    downloads.mkdir(exist_ok=True)
    source_format = spec.get('source_format', 'qcow2' if target.startswith('guix-') else 'iso')
    image = downloads / (target + ('.qcow2' if source_format == 'qcow2' else '.iso'))
    if not image.exists():
        temporary = image.with_suffix(image.suffix + '.part')
        run(['curl', '--fail', '--location', '--retry', '3', '--continue-at', '-',
             '--output', str(temporary), spec['url']])
        if sha256(temporary) != spec['sha256']:
            raise RuntimeError('download checksum mismatch: ' + str(temporary))
        temporary.rename(image)
    if sha256(image) != spec['sha256']:
        raise RuntimeError('release image checksum mismatch: ' + str(image))
    prepared = destination / 'prepared.json'
    metadata = json.loads(prepared.read_text()) if prepared.exists() else {}
    if target == 'guix-i686':
        reusable = (metadata.get('source_sha256') == spec['sha256'] and
                    all((destination / name).exists() for name in ('kernel', 'initrd', 'rootfs.raw')) and
                    sha256(destination / 'kernel') == spec['kernel_sha256'] and
                    sha256(destination / 'initrd') == metadata.get('derived_initrd_sha256') and
                    sha256(destination / 'rootfs.raw') == metadata.get('rootfs_sha256'))
        if not reusable:
            metadata = {'source_sha256': spec['sha256'],
                        **prepare_guix_i686(image, destination, spec)}
            prepared.write_text(json.dumps(metadata, indent=2) + '\n')
    else:
        if not all((destination / name).exists() and
                   sha256(destination / name) == spec[name + '_sha256'] for name in ('kernel', 'initrd')):
            extract = extract_guix if target.startswith('guix-') else extract_nixos
            extract(image, destination, spec)
        for name in ('kernel', 'initrd'):
            if sha256(destination / name) != spec[name + '_sha256']:
                raise RuntimeError(name + ' checksum mismatch')
    share = root / 'share'
    share.mkdir(exist_ok=True)
    key = root / 'id_ed25519'
    if not key.exists():
        run(['ssh-keygen', '-q', '-t', 'ed25519', '-N', '', '-f', str(key)])
    shutil.copyfile(str(key) + '.pub', share / 'id_ed25519.pub')
    (share / 'setup-ssh').write_text(ssh_setup())
    override = profile_name
    profile_name = profile_name or spec['profile']
    site_name = profile_name if override else target
    site = root / ('site-' + site_name + '.json')
    site.write_text(json.dumps({'targets': {profile_name: profile(root, target, spec, profile_name)}}, indent=2) + '\n')
    (destination / 'inputs.json').write_text(json.dumps(spec, indent=2) + '\n')
    print(site)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('target', choices=sorted(IMAGES))
    parser.add_argument('--root', type=Path, required=True, help='directory for images, credentials, and generated site files')
    parser.add_argument('--profile', help='override the emitted harness profile name; this reuses the target kernel and guest while a profile may build or test a different userland architecture')
    args = parser.parse_args()
    prepare(args.root.resolve(), args.target, args.profile)


if __name__ == '__main__':
    main()
