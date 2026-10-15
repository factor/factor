#!/usr/bin/env bash
# Usage: sparc-safepoint-map.sh HOST_FACTOR HOST_IMAGE [OUTPUT]
set -euo pipefail
probe_root=$(cd "$(dirname "$0")/../.." && pwd)
probe_output=${3:-$probe_root/artifacts/safepoint}
mkdir -p "$probe_output"
probe_output=$(cd "$probe_output" && pwd)
# Explicit files update a historical host image without modifying that image.
"$1" -i="$2" -no-monitors -e="USING: command-line namespaces parser vocabs.loader ;
\"$probe_root/core/system/system.factor\" run-file
\"$probe_root/basis/cpu/architecture/architecture.factor\" run-file
\"compiler.constants\" reload \"compiler.codegen.relocation\" reload
\"$probe_root/basis/compiler/codegen/gc-maps/gc-maps.factor\" run-file \"$probe_root/basis/compiler/codegen/codegen.factor\" run-file
\"cpu.sparc\" require \"$probe_root/basis/cpu/sparc/sparc.factor\" run-file
{ \"$probe_output\" } command-line set
\"$probe_root/misc/qemu/sparc-safepoint-map.factor\" run-file"
for probe_bits in 32 64; do
  probe_flags=()
  probe_qemu=qemu-sparc64
  if [[ $probe_bits = 32 ]]; then probe_flags=(-m32); probe_qemu=qemu-sparc32plus; fi
  sparc64-linux-gnu-g++ "${probe_flags[@]}" -O2 -static \
    "$probe_root/vm/tests/sparc-safepoint-map.cpp" -o "$probe_output/map$probe_bits"
  "$probe_qemu" "$probe_output/map$probe_bits" "$probe_output/poll$probe_bits.bin" \
    "$(cat "$probe_output/poll$probe_bits.offset")"
done
