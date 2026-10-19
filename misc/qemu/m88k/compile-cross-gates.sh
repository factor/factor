#!/bin/sh
# Independent object-code gates; guest linking/execution is required afterward.
set -eu
assets=${M88K_ASSETS:-"$PWD/work/qemu-matrix/m88k"}
compiler=${M88K_CLANG:-"$assets/llvm-build/bin/clang++"}
sources=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
mkdir -p "$assets/cxx17"
gate_status=0
for gate in probe int64 publication atomics exceptions; do
    if "$compiler" --target=m88k-unknown-openbsd -mcpu=mc88100 -std=c++17 \
        -O2 -fno-pic -fno-pie -fsjlj-exceptions -c "$sources/cxx17-$gate.cpp" -o "$assets/cxx17/$gate.o" \
        > "$assets/cxx17/$gate.log" 2>&1; then
        printf '%s object-code gate PASS\n' "$gate"
    else
        printf '%s object-code gate FAIL; see %s\n' "$gate" "$assets/cxx17/$gate.log"
        gate_status=1
    fi
done
exit "$gate_status"
