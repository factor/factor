#!/bin/sh
# Object verification only; native OpenBSD linking and execution are required.
set -eu
assets=${M88K_ASSETS:-"$PWD/work/qemu-matrix/m88k"}
compiler=${M88K_CLANG:-"$assets/llvm-build/bin/clang++"}
sources=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
mkdir -p "$assets/cxx17"
for level in 0 2; do
    "$compiler" --target=m88k-unknown-openbsd -mcpu=mc88100 -std=c++17 \
        -O"$level" -fno-pic -fno-pie -fsjlj-exceptions -mllvm -verify-machineinstrs \
        -c "$sources/cxx17-sjlj-acceptance.cpp" -o "$assets/cxx17/sjlj-acceptance-O$level.o"
done
"$compiler" --target=m88k-unknown-openbsd -mcpu=mc88100 -std=c++17 \
    -O2 -fno-pic -fno-pie -fsjlj-exceptions -mllvm -verify-machineinstrs \
    -c "$sources/cxx17-exceptions.cpp" -o "$assets/cxx17/exceptions-sjlj.o"
"$compiler" --target=m88k-unknown-openbsd -c "$sources/cxx17-sjlj-poison.S" \
    -o "$assets/cxx17/sjlj-poison.o"
"$compiler" --target=m88k-unknown-openbsd -O0 -mllvm -verify-machineinstrs \
    -c "$sources/cxx17-extend.ll" -o "$assets/cxx17/extend.o"
"$compiler" --target=m88k-unknown-openbsd -O0 -mllvm -verify-machineinstrs \
    -c "$sources/cxx17-remainder.ll" -o "$assets/cxx17/remainder.o"
"$compiler" --target=m88k-unknown-openbsd -O0 -mllvm -verify-machineinstrs \
    -c "$sources/cxx17-fcmp.ll" -o "$assets/cxx17/fcmp.o"
"$compiler" --target=m88k-unknown-openbsd -O0 -mllvm -verify-machineinstrs \
    -c "$sources/cxx17-clz.ll" -o "$assets/cxx17/clz.o"
"$compiler" --target=m88k-unknown-openbsd -O0 -mllvm -verify-machineinstrs \
    -mllvm -m88k-enable-prelegalizer=false -mllvm -m88k-enable-postcombiner=false \
    -c "$sources/cxx17-commute.ll" -o "$assets/cxx17/commute.o"
"$compiler" --target=m88k-unknown-openbsd -O2 -mllvm -verify-machineinstrs \
    -c "$sources/cxx17-fence.c" -o "$assets/cxx17/fence.o"
"$compiler" --target=m88k-unknown-openbsd -O0 -mllvm -verify-machineinstrs \
    -c "$sources/cxx17-hoist-shift.ll" -o "$assets/cxx17/hoist-shift.o"
for source in bitfield math; do
    "$compiler" --target=m88k-unknown-openbsd -std=c++17 -O2 -fno-pic -fno-pie \
        -mllvm -verify-machineinstrs -c "$sources/cxx17-$source.cpp" \
        -o "$assets/cxx17/$source.o"
done
