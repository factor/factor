#!/usr/bin/env bash
set -euo pipefail
# Prove the VM's publication operations use V8 instructions and no atomic
# runtime helpers. The cross sysroot libc is V8+, so QEMU runs sparc32plus;
# the tested object itself is compiled strictly for V8 under TSO and PSO.
repo=$(cd "$(dirname "$0")/../.." && pwd)
out=${1:-/tmp/factor-sparc-v8-publication}
mkdir -p "$out"
cxx=${SPARC_CXX:-sparc64-linux-gnu-g++}
nm=${SPARC_NM:-sparc64-linux-gnu-nm}
objdump=${SPARC_OBJDUMP:-sparc64-linux-gnu-objdump}
for model in tso pso; do
  flags=(-m32 -mcpu=v8 -mno-v8plus -mmemory-model="$model" -O2 -std=c++17)
  if [[ -n ${FACTOR_PUBLICATION_ROUNDS:-} ]]; then
    flags+=(-DFACTOR_PUBLICATION_ROUNDS="$FACTOR_PUBLICATION_ROUNDS")
  fi
  "$cxx" "${flags[@]}" -c "$repo/vm/tests/atomic-publication.cpp" -o "$out/$model.o"
  "$nm" -u "$out/$model.o" > "$out/$model.undefined"
  if rg '__atomic_|__sync_' "$out/$model.undefined"; then exit 1; fi
  "$objdump" -dr "$out/$model.o" > "$out/$model.asm"
  if rg '\b(cas|casx|casa|casxa|membar|ldx|stx|sllx|srlx|srax)\b' "$out/$model.asm"; then exit 1; fi
  "$cxx" "${flags[@]}" -static -pthread "$repo/vm/tests/atomic-publication.cpp" -o "$out/$model"
  if [[ ${QEMU_USER:-1} == 1 ]]; then qemu-sparc32plus "$out/$model"; fi
done
