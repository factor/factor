#!/bin/sh
# Link both objects with native libc; compile the C source with GCC as an oracle.
set -eu
assets=${M88K_ASSETS:-"$PWD/work/qemu-matrix/m88k"}
compiler=${M88K_CLANG:-"$assets/llvm-build/bin/clang"}
sources=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
mkdir -p "$assets/varargs"
for probe in varargs-numeric-probe.c varargs-zero.ll; do
    "$compiler" --target=m88k-unknown-openbsd --sysroot="$assets/sysroot" \
        -O1 -fno-pic -fno-pie -mllvm -verify-machineinstrs \
        -c "$sources/$probe" -o "$assets/varargs/${probe%.*}.o"
done
