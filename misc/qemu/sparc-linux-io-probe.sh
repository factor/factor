#!/usr/bin/env bash
set -euo pipefail
probe_root=$(cd -- "$(dirname -- "$0")/../.." && pwd)
output=${1:?usage: sparc-linux-io-probe.sh OUTPUT_DIRECTORY}
mkdir -p "$output"
for width in 32 64; do
    sparc64-linux-gnu-gcc -m"$width" -mcpu=v9 -static "$probe_root/misc/qemu/sparc-linux-io-probe.c" -o "$output/probe$width"
    if [ "$width" = 32 ]; then emulator=qemu-sparc32plus; else emulator=qemu-sparc64; fi
    "$emulator" "$output/probe$width" > "$output/run$width.log"
    cat "$output/run$width.log"
done
sha256sum "$output"/probe{32,64} "$output"/run{32,64}.log > "$output/sha256.txt"
