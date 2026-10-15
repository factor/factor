#!/usr/bin/env bash
# Usage: sparc-entry-gc.sh HOST_FACTOR HOST_IMAGE [OUTPUT]
# QEMU_USER=0 builds probes for a real kernel without executing QEMU-user.
set -euo pipefail
probe_root=$(cd "$(dirname "$0")/../.." && pwd)
probe_output=${3:-$probe_root/artifacts/entry-gc}
mkdir -p "$probe_output"/{32,64}
probe_output=$(cd "$probe_output" && pwd)
"$1" -i="$2" -resource-path="$probe_root" -no-monitors -e="USING: command-line namespaces parser vocabs.loader ;
\"$probe_root/core/system/system.factor\" run-file
\"$probe_root/basis/cpu/architecture/architecture.factor\" run-file
\"compiler.constants\" reload \"compiler.codegen.relocation\" reload
\"$probe_root/basis/compiler/cfg/instructions/instructions.factor\" run-file
\"$probe_root/basis/compiler/codegen/gc-maps/gc-maps.factor\" run-file
\"$probe_root/basis/compiler/codegen/codegen.factor\" run-file
\"cpu.sparc\" require \"$probe_root/basis/cpu/sparc/sparc.factor\" run-file
\"compiler.cfg.builder\" require \"$probe_root/basis/compiler/cfg/builder/builder.factor\" run-file
{ \"$probe_output\" } command-line set
\"$probe_root/misc/qemu/sparc-entry-gc.factor\" run-file"
for probe_bits in 32 64; do
  cmp "$probe_output/$probe_bits/current.bin" "$probe_output/$probe_bits/after.bin"
  cmp "$probe_output/$probe_bits/current.reloc" "$probe_output/$probe_bits/after.reloc"
  probe_flags=()
  probe_qemu=qemu-sparc64
  if [[ $probe_bits = 32 ]]; then probe_flags=(-m32); probe_qemu=qemu-sparc32plus; fi
  sparc64-linux-gnu-gcc "${probe_flags[@]}" -O2 -ffunction-sections -fdata-sections \
    -ffixed-g2 -ffixed-g3 -ffixed-g4 -ffixed-g5 -c "$probe_root/src/sparc_linux_signal.c" \
    -o "$probe_output/zig-bridge$probe_bits.o"
  sparc64-linux-gnu-g++ "${probe_flags[@]}" -O2 -static -ffixed-g2 -ffixed-g3 -ffixed-g4 -ffixed-g5 \
    -ffunction-sections -fdata-sections -Wl,--gc-sections \
    "$probe_root/vm/tests/sparc-entry-gc.cpp" "$probe_root/vm/tests/sparc-entry-gc.S" \
    "$probe_root/vm/sparc-linux-sigreturn.S" "$probe_root/vm/code_heap.cpp" \
    "$probe_output/zig-bridge$probe_bits.o" -o "$probe_output/probe$probe_bits"
  if [[ ${QEMU_USER:-1} = 1 ]]; then
    for probe_position in before after current; do
      "$probe_qemu" "$probe_output/probe$probe_bits" "$probe_output/$probe_bits" "$probe_position"
    done
    "$probe_qemu" "$probe_output/probe$probe_bits" "$probe_output/$probe_bits" current zig
  fi
done
