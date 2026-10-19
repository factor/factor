#!/usr/bin/env bash
# GCC supplies the SPARC GNU linker and libc startup; Zig supplies LLVM objects.
set -euo pipefail
repo=$(cd "$(dirname "$0")/../.." && pwd)
zig=${ZIG:-zig}
out=${SPARC_PROBE_OUT:-"$repo/.sparc-zig-probe"}
mkdir -p "$out"
export ZIG_GLOBAL_CACHE_DIR=${ZIG_GLOBAL_CACHE_DIR:-"$out/global-cache"}
for bits in 32 64; do
    arch=sparc
    qemu=qemu-sparc32plus
    gcc_args=(-m32 -mcpu=v9)
    sysroot="$out/sysroot32"
    mkdir -p "$sysroot"
    ln -sfn /usr/sparc64-linux-gnu/lib32 "$sysroot/lib"
    if [[ $bits == 64 ]]; then
        arch=sparc64
        qemu=qemu-sparc64
        gcc_args=(-m64)
        sysroot=/usr/sparc64-linux-gnu
    fi
    "$zig" build-obj -O ReleaseFast -target "$arch-linux-gnu" -fllvm \
        --cache-dir "$out/cache-$bits" -femit-bin="$out/probe-$bits.o" \
        --dep sparc --dep sparc_runtime -Mroot="$repo/misc/qemu/sparc-toolchain-probe.zig" \
        -Msparc="$repo/src/sparc.zig" -Msparc_runtime="$repo/src/sparc_compiler_rt.zig"
    sparc64-linux-gnu-gcc "${gcc_args[@]}" -c "$repo/src/sparc_linux_signal.c" -o "$out/signal-$bits.o"
    sparc64-linux-gnu-g++ "${gcc_args[@]}" "$repo/misc/qemu/sparc-toolchain-probe.cpp" \
        "$out/probe-$bits.o" "$out/signal-$bits.o" -o "$out/probe-$bits"
    "$qemu" -L "$sysroot" "$out/probe-$bits"
done
