#!/usr/bin/env bash
set -euo pipefail
root=${1:?}; arch=${2:?}
case "$arch" in
 mipsel|mips64el) modules=$'ata_piix\nsd_mod\next4';;
 powerpc) modules=$'pata_macio\nsd_mod\next4';;
 ppc64) modules=$'virtio_pci\nvirtio_blk\next4';;
 sparc64) modules=$'pata_cmd64x\nsd_mod\next4';;
 m68k) modules=$'mac_esp\nsd_mod\next4';;
 *) exit 0;;
esac
sudo mkdir -p "$root/etc/initramfs-tools/conf.d"
printf 'MODULES=list\n' | sudo tee "$root/etc/initramfs-tools/conf.d/factor-infrastructure" >/dev/null
printf '%s\n' "$modules" | sudo tee "$root/etc/initramfs-tools/modules" >/dev/null
