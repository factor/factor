#!/usr/bin/env bash
set -euo pipefail
here=$(cd -- "$(dirname -- "$0")" && pwd)
assets=${FACTOR_HPPA_ASSETS:-$here/../../../work/qemu-matrix/new-linux/hppa}
mkdir -p "$assets"
cc=${CC:-hppa-linux-gnu-gcc}
qemu=${QEMU_HPPA:-qemu-hppa}
sysroot=${HPPA_SYSROOT:-/usr/hppa-linux-gnu}
"$cc" -O2 -Wall -Wextra "$here/gate-probe.c" "$here/gate-probe.S" "$here/../../../vm/cpu-hppa-trampoline.S" -o "$assets/gate-probe"
"$cc" --version > "$assets/gate-toolchain.txt"
"$qemu" --version >> "$assets/gate-toolchain.txt"
sha256sum "$here/gate-probe.c" "$here/gate-probe.S" "$here/../../../vm/cpu-hppa-trampoline.S" "$assets/gate-probe" >> "$assets/gate-toolchain.txt"
"$qemu" -L "$sysroot" "$assets/gate-probe" | tee "$assets/gate-probe.log"
