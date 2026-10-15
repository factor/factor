#!/usr/bin/env bash
# Preserve the compiler failure status: unsupported code generation is not a pass.
set -euo pipefail
repo=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
build=$(mktemp -d)
trap 'rm -rf -- "$build"' EXIT
export ZIG_GLOBAL_CACHE_DIR="$build/global-cache"
export ZIG_LOCAL_CACHE_DIR="$build/local-cache"
"${ZIG:-zig}" build-exe -target m68k-linux-gnu -lc \
    "$repo/vm/tests/m68k/zig-libc-probe.zig" -femit-bin="$build/zig-libc-probe"
"${M68K_QEMU:-qemu-m68k}" -L "${M68K_SYSROOT:-/usr/m68k-linux-gnu}" "$build/zig-libc-probe"
