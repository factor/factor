#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
assets=${FACTOR_QEMU_ASSETS:-/home/sheeple/factor/work/qemu-matrix/new-linux/ppc64be}
port=${FACTOR_QEMU_SSH_PORT:-22905}
root=$assets/root
mkdir -p "$assets"
"$(dirname "$0")/provision-rootfs.sh" ppc64 unstable linux-image-powerpc64 "$assets" https://deb.debian.org/debian-ports
if [[ -f "$assets/guest.pid" ]] && kill -0 "$(cat "$assets/guest.pid")" 2>/dev/null; then
 echo 'Guest already running'; exit 0
fi
prepare_guest_disk "$assets" factor-ppc64be /dev/vda dhcpcd-base
kernel=$(find "$root/boot" "$root/usr/lib/modules" -maxdepth 3 -name 'vmlinu?-*' | sort | tail -1)
initrd=$(find "$root/boot" "$root/usr/lib/modules" -maxdepth 3 -name 'initrd.img-*' | sort | tail -1)
qemu-system-ppc64 -machine pseries -cpu power9 -m 2048 -smp 2 -accel tcg -display none -serial file:"$assets/console.log" -kernel "$kernel" -initrd "$initrd" -append 'root=/dev/vda rw console=hvc0 net.ifnames=0' -drive file="$assets/guest.raw",format=raw,if=virtio -device virtio-net-pci,netdev=net0 -netdev user,id=net0,hostfwd=tcp:127.0.0.1:"$port"-:22 -daemonize -pidfile "$assets/guest.pid"
echo "PPC64BE guest started; SSH root@127.0.0.1 port $port"
