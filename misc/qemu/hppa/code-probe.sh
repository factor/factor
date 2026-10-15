#!/usr/bin/env bash
set -euo pipefail
here=$(cd -- "$(dirname -- "$0")" && pwd)
assets=${FACTOR_HPPA_ASSETS:-$here/../../../work/qemu-matrix/new-linux/hppa}
mkdir -p "$assets"
cc=${CXX:-hppa-linux-gnu-g++}
qemu=${QEMU_HPPA:-qemu-hppa}
sysroot=${HPPA_SYSROOT:-/usr/hppa-linux-gnu}
"$cc" -O2 -Wall -Wextra "$here/code-probe.cpp" -o "$assets/code-probe"
"$cc" --version > "$assets/code-toolchain.txt"
"$qemu" --version >> "$assets/code-toolchain.txt"
sha256sum "$here/code-probe.cpp" "$here/../../../vm/hppa.hpp" "$assets/code-probe" >> "$assets/code-toolchain.txt"
"$qemu" -L "$sysroot" "$assets/code-probe" | tee "$assets/code-probe.log"
