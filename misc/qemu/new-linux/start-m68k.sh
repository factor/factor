#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
assets=${FACTOR_QEMU_ASSETS:-/home/sheeple/factor/work/qemu-matrix/new-linux/m68k}
port=${FACTOR_QEMU_SSH_PORT:-22907}
root=$assets/root
mkdir -p "$assets"
"$(dirname "$0")/provision-rootfs.sh" m68k unstable linux-image-m68k "$assets" https://deb.debian.org/debian-ports
if [[ -f "$assets/guest.pid" ]] && kill -0 "$(cat "$assets/guest.pid")" 2>/dev/null; then
 echo 'Guest already running'; exit 0
fi
prepare_guest_disk "$assets" factor-m68k /dev/sda dhcpcd-base
kernel=$(find "$root/boot" "$root/usr/lib/modules" -maxdepth 3 -name 'vmlinu?-*' | sort | tail -1)
initrd=$(find "$root/boot" "$root/usr/lib/modules" -maxdepth 3 -name 'initrd.img-*' | sort | tail -1)
qemu-system-m68k -machine q800,audiodev=none -audiodev none,id=none -m "${FACTOR_QEMU_RAM:-512}" -smp 1 -accel tcg -display none -serial file:"$assets/console.log" -kernel "$kernel" -initrd "$initrd" -append 'root=/dev/sda rw console=ttyS0 net.ifnames=0' -drive file="$assets/guest.raw",format=raw,if=scsi -nic user,hostfwd=tcp:127.0.0.1:"$port"-:22 -daemonize -pidfile "$assets/guest.pid"
echo "m68k q800 guest started; SSH root@127.0.0.1 port $port"
