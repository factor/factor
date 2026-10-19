#!/usr/bin/env bash
set -euo pipefail
here=$(cd -- "$(dirname -- "$0")" && pwd)
assets=${FACTOR_HPPA_ASSETS:-$here/../../../work/qemu-matrix/new-linux/hppa}
mkdir -p "$assets"
cc=${CC:-hppa-linux-gnu-gcc}
qemu=${QEMU_HPPA:-qemu-hppa}
sysroot=${HPPA_SYSROOT:-/usr/hppa-linux-gnu}
"$cc" -O2 -Wall -Wextra "$here/signal-probe.c" "$here/signal-probe.S" -o "$assets/signal-probe"
"$cc" --version > "$assets/signal-toolchain.txt"
"$qemu" --version >> "$assets/signal-toolchain.txt"
sha256sum "$here/signal-probe.c" "$here/signal-probe.S" "$assets/signal-probe" >> "$assets/signal-toolchain.txt"
"$qemu" -L "$sysroot" "$assets/signal-probe" | tee "$assets/signal-probe.log"
