#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
assets=${FACTOR_QEMU_ASSETS:-/home/sheeple/factor/work/qemu-matrix/new-linux/sparc64}
port=${FACTOR_QEMU_SSH_PORT:-22906}
root=$assets/root
mkdir -p "$assets"
"$(dirname "$0")/provision-rootfs.sh" sparc64 unstable linux-image-sparc64 "$assets" https://deb.debian.org/debian-ports
if [[ -f "$assets/guest.pid" ]] && kill -0 "$(cat "$assets/guest.pid")" 2>/dev/null; then
 echo 'Guest already running'; exit 0
fi
prepare_guest_disk "$assets" factor-sparc64 /dev/sda dhcpcd-base
kernel=$(find "$root/boot" "$root/usr/lib/modules" -maxdepth 3 -name 'vmlinu?-*' | sort | tail -1)
initrd=$(find "$root/boot" "$root/usr/lib/modules" -maxdepth 3 -name 'initrd.img-*' | sort | tail -1)
qemu-system-sparc64 -machine sun4u -m 1024 -smp 1 -accel tcg -display none -serial file:"$assets/console.log" -kernel "$kernel" -initrd "$initrd" -append 'root=/dev/sda rw console=ttyS0 net.ifnames=0' -drive file="$assets/guest.raw",format=raw,if=ide -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp:127.0.0.1:"$port"-:22 -daemonize -pidfile "$assets/guest.pid"
echo "SPARC64 sun4u guest started; SSH root@127.0.0.1 port $port"
