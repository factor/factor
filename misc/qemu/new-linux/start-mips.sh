#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
arch=${1:-mipsel}
case "$arch" in mipsel) qemu=qemu-system-mipsel; cpu=24Kf; kernel_package=linux-image-4kc-malta; default_port=22903;; mips64el) qemu=qemu-system-mips64el; cpu=MIPS64R2-generic; kernel_package=linux-image-5kc-malta; default_port=22904;; *) echo "Use mipsel or mips64el" >&2; exit 1;; esac
assets=${FACTOR_QEMU_ASSETS:-/home/sheeple/factor/work/qemu-matrix/new-linux/$arch}
port=${FACTOR_QEMU_SSH_PORT:-$default_port}
root=$assets/root
mkdir -p "$assets"
"$(dirname "$0")/provision-rootfs.sh" "$arch" bookworm "$kernel_package" "$assets"
if [[ -f "$assets/guest.pid" ]] && kill -0 "$(cat "$assets/guest.pid")" 2>/dev/null; then
 echo 'Guest already running'; exit 0
fi
prepare_guest_disk "$assets" factor-mips /dev/sda isc-dhcp-client
kernel=$(find "$root/boot" "$root/usr/lib/modules" -maxdepth 3 -name 'vmlinu?-*' | sort | tail -1)
initrd=$(find "$root/boot" "$root/usr/lib/modules" -maxdepth 3 -name 'initrd.img-*' | sort | tail -1)
"$qemu" -machine malta -cpu "$cpu" -m 1024 -smp 1 -accel tcg -display none -serial file:"$assets/console.log" -kernel "$kernel" -initrd "$initrd" -append 'root=/dev/sda rw console=ttyS0 net.ifnames=0' -drive file="$assets/guest.raw",format=raw,if=ide -device pcnet,netdev=net0 -netdev user,id=net0,hostfwd=tcp:127.0.0.1:"$port"-:22 -daemonize -pidfile "$assets/guest.pid"
echo "$arch guest started; SSH root@127.0.0.1 port $port"
