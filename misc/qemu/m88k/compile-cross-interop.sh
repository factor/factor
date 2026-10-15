#!/bin/sh
# Compile caller and callee independently; link both crossing directions natively.
set -eu
assets=${M88K_ASSETS:-"$PWD/work/qemu-matrix/m88k"}
compiler=${M88K_CLANG:-"$assets/llvm-build/bin/clang"}
sources=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
mkdir -p "$assets/interop"
for opt in 0 1; do
    "$compiler" --target=m88k-unknown-openbsd --sysroot="$assets/sysroot" \
        "-O$opt" -fno-pic -fno-pie -mllvm -verify-machineinstrs \
        -c "$sources/varargs-interop-probe.c" -o "$assets/interop/callee-o$opt.o"
    "$compiler" --target=m88k-unknown-openbsd --sysroot="$assets/sysroot" \
        "-O$opt" -fno-pic -fno-pie -mllvm -verify-machineinstrs \
        -DM88K_INTEROP_CALLER -c "$sources/varargs-interop-probe.c" \
        -o "$assets/interop/caller-o$opt.o"
done
