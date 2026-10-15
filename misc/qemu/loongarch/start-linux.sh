#!/usr/bin/env bash
set -euo pipefail
assets=${FACTOR_QEMU_ASSETS:-/home/sheeple/factor/work/qemu-matrix/new-linux/loongarch64}
port=${FACTOR_QEMU_SSH_PORT:-23103}
root=$assets/root
infra=${FACTOR_QEMU_INFRA_DIR:-$(dirname "$0")/../new-linux}
mkdir -p "$assets"
FACTOR_QEMU_INITRAMFS_PACKAGE=dracut "$infra/provision-rootfs.sh" loong64 unstable linux-image-loong64 "$assets" https://deb.debian.org/debian
if [[ ! -e "$root/boot/vmlinuz" ]] && ! compgen -G "$root/boot/vmlinuz-*" >/dev/null; then
 echo 'Rootfs must complete debootstrap second stage and install linux-image-loong64 before starting.' >&2; exit 1
fi
if [[ -f "$assets/guest.pid" ]] && kill -0 "$(cat "$assets/guest.pid")" 2>/dev/null; then
 echo 'Guest already running'; exit 0
fi
. "$infra/common.sh"
prepare_guest_disk "$assets" factor-loongarch64 /dev/vda dhcpcd-base
kernel=$(find "$root/boot" "$root/usr/lib/modules" -maxdepth 3 \( -name 'vmlinuz-*' -o -name vmlinuz \) | sort | tail -1)
initrd=$(find "$root/boot" "$root/usr/lib/modules" -maxdepth 3 -name 'initrd.img-*' | sort | tail -1)
sudo install -m 644 "$kernel" "$assets/kernel"
sudo install -m 644 "$initrd" "$assets/initrd"
qemu-system-loongarch64 -machine virt -m 2048 -smp 2 -accel tcg -display none -serial file:"$assets/console.log" -bios "${FACTOR_QEMU_FIRMWARE:-/usr/share/qemu-efi-loongarch64/QEMU_EFI.fd}" -kernel "$assets/kernel" -initrd "$assets/initrd" -append 'root=/dev/vda rw console=ttyS0 net.ifnames=0' -drive file="$assets/guest.raw",format=raw,if=none,id=root -device virtio-blk-pci,drive=root -device virtio-net-pci,netdev=net0 -netdev user,id=net0,hostfwd=tcp:127.0.0.1:"$port"-:22 -daemonize -pidfile "$assets/guest.pid"
echo "LoongArch64 guest started; SSH root@127.0.0.1 port $port"
