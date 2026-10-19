#!/bin/bash
set -euo pipefail
root=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
build=${ALPHA_PROBE_BUILD:-"$root/build-alpha"}
mkdir -p "$build"
alpha-linux-gnu-g++ -O2 -mieee -mfp-rounding-mode=d -frounding-math -pthread \
  "$root/vm/tests/alpha-native.cpp" -o "$build/alpha-native"
qemu-alpha -L "${ALPHA_SYSROOT:-/usr/alpha-linux-gnu}" "$build/alpha-native"
