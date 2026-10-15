#!/usr/bin/env bash
set -euo pipefail
: "${FACTOR_BIN:?Set FACTOR_BIN to the host Factor executable}"
: "${FACTOR_IMAGE:?Set FACTOR_IMAGE to its image}"
: "${SH_QEMU:?Set SH_QEMU to the validated SH4 QEMU executable}"
mkdir -p artifacts
"$FACTOR_BIN" -i="$FACTOR_IMAGE" -resource-path="$PWD" basis/cpu/sh/codegen/native/emit.factor
${SH_CC:-sh4-linux-gnu-gcc} -m4 -Wa,--isa=sh4 -static -no-pie \
  basis/cpu/sh/codegen/native/probe.c basis/cpu/sh/codegen/native/probe.S \
  -o artifacts/sh-emitter-probe.new
mv artifacts/sh-emitter-probe.new artifacts/sh-emitter-probe
"$SH_QEMU" -L "${SH_SYSROOT:-/usr/sh4-linux-gnu}" artifacts/sh-emitter-probe
