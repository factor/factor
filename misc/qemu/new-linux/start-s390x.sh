#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
assets=${FACTOR_QEMU_ASSETS:-/home/sheeple/factor/work/qemu-matrix/new-linux/s390x}
port=${FACTOR_QEMU_SSH_PORT:-22902}
root=$assets/root
mkdir -p "$assets"
if [[ ! -x "$root/bin/bash" ]]; then
 sudo debootstrap --foreign --arch=s390x --variant=minbase --include=systemd-sysv,ifupdown,isc-dhcp-client,iproute2,openssh-server,gcc,g++,make,bash,ca-certificates,libssl-dev,libcapstone-dev,linux-image-s390x trixie "$root" https://deb.debian.org/debian
 sudo chroot "$root" /debootstrap/debootstrap --second-stage
fi
if [[ ! -e "$root/boot/vmlinuz" ]] && ! compgen -G "$root/boot/vmlinuz-*" >/dev/null; then
 echo 'Rootfs must complete debootstrap second stage and install linux-image-s390x before starting.' >&2; exit 1
fi
if [[ -f "$assets/guest.pid" ]] && kill -0 "$(cat "$assets/guest.pid")" 2>/dev/null; then
 echo 'Guest already running'; exit 0
fi
prepare_guest_disk "$assets" factor-s390x /dev/vda isc-dhcp-client
kernel=$(find "$root/boot" "$root/usr/lib/modules" -maxdepth 3 -name 'vmlinuz-*' | sort | tail -1)
initrd=$(find "$root/boot" "$root/usr/lib/modules" -maxdepth 3 -name 'initrd.img-*' | sort | tail -1)
qemu-system-s390x -machine s390-ccw-virtio -m 2048 -smp 2 -accel tcg -display none -serial file:"$assets/console.log" -kernel "$kernel" -initrd "$initrd" -append 'root=/dev/vda rw console=ttysclp0 net.ifnames=0' -drive file="$assets/guest.raw",format=raw,if=virtio -device virtio-net-ccw,netdev=net0 -netdev user,id=net0,hostfwd=tcp:127.0.0.1:"$port"-:22 -daemonize -pidfile "$assets/guest.pid"
echo "s390x guest started; SSH root@127.0.0.1 port $port"
