#!/usr/bin/env bash
set -euo pipefail
probe_root=$(cd -- "$(dirname -- "$0")/../.." && pwd)
resource=${FACTOR_PROBE_RESOURCE:-$probe_root}
output=$3
mkdir -p "$output"
"$1" -i="$2" -resource-path="$resource" -no-monitors "$probe_root/misc/sparc/large-frame-probe.factor" "$output"
for width in 32 64; do
 flags=(); emulator=qemu-sparc64
 if [[ $width == 32 ]]; then flags=(-m32 -mcpu=v9); emulator=qemu-sparc32plus; fi
 sparc64-linux-gnu-gcc -O2 -static "${flags[@]}" "$probe_root/misc/sparc/large-frame-probe.c" "$probe_root/misc/sparc/backend-compiler-entry.S" -o "$output/probe$width"
 "$emulator" "$output/probe$width" "$output"
done
