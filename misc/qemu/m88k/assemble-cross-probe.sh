#!/bin/sh
# Produces an OpenBSD/m88k object; native guest execution is a separate gate.
set -eu
assets=${M88K_ASSETS:-"$PWD/work/qemu-matrix/m88k"}
sources=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
mkdir -p "$assets/cross-assembler"
"$assets/llvm-build/bin/llvm-mc" -triple=m88k-unknown-openbsd \
    -mcpu=mc88100 -filetype=obj "$sources/native-code.S" \
    -o "$assets/cross-assembler/native-code.o"
"$assets/llvm-build/bin/llvm-objdump" -d "$assets/cross-assembler/native-code.o" \
    > "$assets/cross-assembler/native-code.disasm"
printf 'm88k cross-assembler object ready: %s\n' "$assets/cross-assembler/native-code.o"
