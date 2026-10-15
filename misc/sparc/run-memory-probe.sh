#!/usr/bin/env bash
set -euo pipefail
repo=$(cd "$(dirname "$0")/../.." && pwd)
resource=${SPARC_MEMORY_RESOURCE:-$repo}
out=${SPARC_MEMORY_OUTPUT:-$(mktemp -d /tmp/factor-sparc-memory.XXXXXX)}
mkdir -p "$out"
"$repo/factor" -i="$repo/factor.image" -resource-path="$resource" -no-user-init -no-monitors "$repo/misc/sparc/backend-memory-probe.factor" "$out"
for width in 32 64; do
 flags=()
 if [[ $width == 32 ]]; then flags=(-m32 -mcpu=v9); fi
 sparc64-linux-gnu-gcc "${flags[@]}" -O2 -static -ffixed-g2 -ffixed-g3 -ffixed-g4 -ffixed-g5 "$repo/misc/sparc/backend-memory-probe.c" -o "$out/probe$width"
 emulator=qemu-sparc64
 if [[ $width == 32 ]]; then emulator=qemu-sparc32plus; fi
 "$emulator" "$out/probe$width" "$out"
done
