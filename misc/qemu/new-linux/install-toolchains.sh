#!/usr/bin/env bash
set -euo pipefail
sudo apt-get install -y --no-install-recommends g++-powerpc-linux-gnu g++-powerpc64-linux-gnu g++-powerpc64le-linux-gnu g++-multilib-sparc64-linux-gnu g++-s390x-linux-gnu g++-arm-linux-gnueabihf g++-m68k-linux-gnu qemu-system-ppc qemu-system-mips qemu-system-sparc qemu-system-s390x gdb-multiarch
base=${FACTOR_TOOLCHAINS:-/home/sheeple/factor/work/qemu-matrix/new-linux/toolchains}
mkdir -p "$base"
for arch in mips32 mips32el mips64-n32 mips64el-n32; do
 name=$arch--glibc--stable-2026.08-1
 if [[ ! -d "$base/$name" ]]; then
  curl -fL "https://toolchains.bootlin.com/downloads/releases/toolchains/$arch/tarballs/$name.tar.xz" -o "$base/$name.tar.xz.part"
  mv "$base/$name.tar.xz.part" "$base/$name.tar.xz"
  tar -xf "$base/$name.tar.xz" -C "$base"
 fi
done
