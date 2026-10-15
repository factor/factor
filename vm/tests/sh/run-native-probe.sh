#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
probe_dir=$(mktemp -d)
trap 'rm -rf -- "$probe_dir"' EXIT
"${SH_CXX:-sh4-linux-gnu-g++}" -std=c++17 -O2 -m4 -Wa,--isa=sh4 -Wall -Wextra \
  "$repo/vm/tests/sh/native-probe.cpp" "$repo/vm/tests/sh/native-bridge.S" \
  -o "$probe_dir/native-probe"
"${SH_QEMU:-qemu-sh4}" -L "${SH_SYSROOT:-/usr/sh4-linux-gnu}" "$probe_dir/native-probe"
"${SH_CXX:-sh4-linux-gnu-g++}" -std=c++17 -O2 -m4 -Wa,--isa=sh4 \
  "$repo/vm/tests/sh/layout-probe.cpp" -o "$probe_dir/layout-probe"
"${SH_QEMU:-qemu-sh4}" -L "${SH_SYSROOT:-/usr/sh4-linux-gnu}" "$probe_dir/layout-probe"
