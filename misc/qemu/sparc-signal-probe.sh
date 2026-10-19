#!/usr/bin/env bash
set -euo pipefail
# Compile and run the exact generated signal stub with the shared bridge.
# Usage: sparc-signal-probe.sh 32|64 GENERATED_DIRECTORY [OUTPUT_BINARY]
# GENERATED_DIRECTORY contains signal.bin and signal.reloc, emitted by
# sparc-signal-template.factor. QEMU_USER=0 builds a real-kernel binary.
width=${1:?width 32 or 64}
generated=${2:?directory containing signal.bin and signal.reloc}
output=${3:-/tmp/factor-sparc${width}-signal-probe}
repo=$(cd "$(dirname "$0")/../.." && pwd)
flags=(-O2 -static -ffixed-g2 -ffixed-g3 -ffixed-g4 -ffixed-g5)
case "$width" in
  32)
    flags+=(-m32)
    runner=qemu-sparc32plus
    if [[ ${QEMU_USER:-1} == 1 ]]; then
      # QEMU 10.2's sparc32plus FPU record disagrees with its native32 PSR.
      # This accommodation is confined to the probe, never the VM bridge.
      flags+=(-DFACTOR_TEST_QEMU_SPARC32PLUS_FPU)
    fi
    ;;
  64) runner=qemu-sparc64 ;;
  *) exit 2 ;;
esac
"${SPARC_CXX:-sparc64-linux-gnu-g++}" "${flags[@]}" -o "$output" \
  "$repo/vm/tests/sparc-signal-resume.cpp" \
  "$repo/vm/tests/sparc-signal-resume.S" \
  "$repo/vm/sparc-linux-sigreturn.S" \
  "$repo/vm/cpu-sparc-trampoline.S"
if [[ ${QEMU_USER:-1} == 1 ]]; then
  "$runner" "$output" "$generated/signal.bin" "$generated/signal.reloc"
fi
