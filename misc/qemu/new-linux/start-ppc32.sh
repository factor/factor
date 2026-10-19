#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
assets=${FACTOR_QEMU_ASSETS:-/home/sheeple/factor/work/qemu-matrix/new-linux/ppc32}
port=${FACTOR_QEMU_SSH_PORT:-22908}
root=$assets/root
mkdir -p "$assets"
"$(dirname "$0")/provision-rootfs.sh" powerpc unstable linux-image-powerpc "$assets" https://deb.debian.org/debian-ports
if [[ -f "$assets/guest.pid" ]] && kill -0 "$(cat "$assets/guest.pid")" 2>/dev/null; then
 echo 'Guest already running'; exit 0
fi
prepare_guest_disk "$assets" factor-ppc32 /dev/sda dhcpcd-base
kernel=$(find "$root/boot" "$root/usr/lib/modules" -maxdepth 3 -name 'vmlinu?-*' | sort | tail -1)
initrd=$(find "$root/boot" "$root/usr/lib/modules" -maxdepth 3 -name 'initrd.img-*' | sort | tail -1)
qemu-system-ppc -machine mac99 -cpu 7400 -m 1024 -smp 1 -accel tcg -display none -serial file:"$assets/console.log" -kernel "$kernel" -initrd "$initrd" -append 'root=/dev/sda rw console=ttyPZ0 net.ifnames=0' -drive file="$assets/guest.raw",format=raw,if=ide -device sungem,netdev=net0 -netdev user,id=net0,hostfwd=tcp:127.0.0.1:"$port"-:22 -daemonize -pidfile "$assets/guest.pid"
echo "PPC32 mac99 guest started; SSH root@127.0.0.1 port $port"
