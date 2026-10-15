#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
assets=${FACTOR_QEMU_ASSETS:-/home/sheeple/factor/work/qemu-matrix/new-linux/hppa}
port=${FACTOR_QEMU_SSH_PORT:-23102}
root=$assets/root
mkdir -p "$assets"
FACTOR_QEMU_INITRAMFS_PACKAGE=dracut "$(dirname "$0")/provision-rootfs.sh" hppa unstable linux-image-parisc "$assets" https://deb.debian.org/debian-ports
if [[ -f "$assets/guest.pid" ]] && kill -0 "$(cat "$assets/guest.pid")" 2>/dev/null; then
 echo 'Guest already running'; exit 0
fi
sudo install -m 644 /usr/share/keyrings/debian-ports-archive-keyring.gpg \
 "$root/etc/apt/trusted.gpg.d/debian-ports.gpg"
# dracut runs in a foreign chroot with no HPPA hardware: explicitly include
# the B160L SCSI controller, root filesystem, and network driver.
if [[ ! -f "$assets/guest.raw" ]]; then
 sudo mkdir -p "$root/etc/dracut.conf.d"
 printf 'hostonly="no"\nadd_drivers+=" sym53c8xx sd_mod ext4 tulip "\n' | sudo tee "$root/etc/dracut.conf.d/hppa-qemu.conf" >/dev/null
 for path in proc sys dev; do
  if ! mountpoint -q "$root/$path"; then sudo mount --bind "/$path" "$root/$path"; fi
 done
 version=$(find "$root/usr/lib/modules" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | tail -1)
 [[ -n "$version" ]]
 sudo chroot "$root" dracut -f "/boot/initrd.img-$version" "$version"
fi
prepare_guest_disk "$assets" factor-hppa /dev/sda dhcpcd-base
kernel=$(find "$root/boot" "$root/usr/lib/modules" -maxdepth 3 \( -name 'vmlinu?-*' -o -name vmlinuz \) | sort | tail -1)
initrd=$(find "$root/boot" -maxdepth 1 -name 'initrd.img-*' | sort | tail -1)
[[ -n "$kernel" && -n "$initrd" ]]
sudo install -m 644 "$kernel" "$assets/kernel"
sudo install -m 644 "$initrd" "$assets/initrd"
# -nographic makes firmware select the serial console and cannot daemonize.
# Detach explicitly while retaining logs and a PID for the guest lifecycle.
python3 - "$assets" "$port" <<'PY'
import pathlib,subprocess,sys
assets=pathlib.Path(sys.argv[1]);port=sys.argv[2]
args=['qemu-system-hppa','-machine','B160L','-m','512','-accel','tcg',
      '-nographic','-monitor','none','-serial',f'file:{assets}/console.log',
      '-kernel',str(assets/'kernel'),'-initrd',str(assets/'initrd'),
      '-append','root=/dev/sda rw console=ttyS0 net.ifnames=0',
      '-drive',f'file={assets}/guest.raw,format=raw',
      '-nic',f'user,model=tulip,hostfwd=tcp:127.0.0.1:{port}-:22']
with open(assets/'qemu.log','ab') as log:
 proc=subprocess.Popen(args,stdin=subprocess.DEVNULL,stdout=log,stderr=log,start_new_session=True)
(assets/'guest.pid').write_text(str(proc.pid)+'\n')
(assets/'qemu-command.txt').write_text(repr(args)+'\n')
PY
echo "HPPA B160L guest started; SSH root@127.0.0.1 port $port"
