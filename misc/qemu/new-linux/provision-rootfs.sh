#!/usr/bin/env bash
set -euo pipefail
arch=${1:?usage: provision-rootfs.sh ARCH SUITE KERNEL_PACKAGE ASSET_DIRECTORY [MIRROR]}
suite=${2:?}; kernel=${3:?}; assets=${4:?}; mirror=${5:-https://deb.debian.org/debian}
assets=$(realpath -m "$assets")
root=$assets/root
mkdir -p "$assets"
args=()
if [[ $mirror == *debian-ports* ]]; then
 args+=(--keyring=/usr/share/keyrings/debian-ports-archive-keyring.gpg)
fi
if [[ ! -x "$root/bin/bash" ]]; then
 sudo debootstrap --foreign --arch="$arch" --variant=minbase "${args[@]}" --include="systemd-sysv,netbase,ifupdown,dhcpcd-base,iproute2,openssh-server,gcc,g++,make,bash,ca-certificates,libssl-dev,libcapstone-dev,$kernel" "$suite" "$root" "$mirror"
fi
"$(dirname "$0")/configure-initramfs.sh" "$root" "$arch"
if [[ ! -f "$assets/rootfs-ready" ]]; then
 if [[ -x "$root/debootstrap/debootstrap" ]]; then
  sudo chroot "$root" /debootstrap/debootstrap --second-stage
 fi
 sudo chroot "$root" dpkg-query -W gcc g++ "$kernel"
 touch "$assets/rootfs-ready"
fi
printf 'Rootfs ready: %s\n' "$root"
