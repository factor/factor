#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
build=$(mktemp -d)
trap 'rm -rf -- "$build"' EXIT
"${M68K_CXX:-m68k-linux-gnu-g++}" -O2 -m68020 -m68881 \
    "$repo/vm/tests/m68k/native-probe.cpp" "$repo/vm/tests/m68k/native-bridge.S" "$repo/vm/tests/m68k/native-abi.c" -o "$build/native-probe"
"${M68K_QEMU:-qemu-m68k}" -L "${M68K_SYSROOT:-/usr/m68k-linux-gnu}" "$build/native-probe"

"${M68K_CXX:-m68k-linux-gnu-g++}" -O2 -m68020 -m68881 -std=c++17 \
    "$repo/vm/tests/layout-probe.cpp" -o "$build/layout-probe"
"${M68K_QEMU:-qemu-m68k}" -L "${M68K_SYSROOT:-/usr/m68k-linux-gnu}" "$build/layout-probe"
