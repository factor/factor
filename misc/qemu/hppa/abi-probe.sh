#!/usr/bin/env bash
set -euo pipefail
here=$(cd -- "$(dirname -- "$0")" && pwd)
assets=${FACTOR_HPPA_ASSETS:-$here/../../../work/qemu-matrix/new-linux/hppa}
mkdir -p "$assets"
cc=${CC:-hppa-linux-gnu-gcc}
qemu=${QEMU_HPPA:-qemu-hppa}
sysroot=${HPPA_SYSROOT:-/usr/hppa-linux-gnu}
"$cc" -O2 -Wall -Wextra "$here/abi-probe.c" -o "$assets/abi-probe" -latomic
"$cc" --version > "$assets/abi-toolchain.txt"
"$qemu" --version >> "$assets/abi-toolchain.txt"
sha256sum "$here/abi-probe.c" "$assets/abi-probe" >> "$assets/abi-toolchain.txt"
"$qemu" -L "$sysroot" "$assets/abi-probe" | tee "$assets/abi-probe.log"
