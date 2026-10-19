#!/bin/sh
# Uses the existing pinned LLVM checkout and an extracted OpenBSD comp/base sysroot.
# Runtime compilation may expose additional target backend gaps.
set -eu
assets=${M88K_ASSETS:-"$PWD/work/qemu-matrix/m88k"}
assets=$(CDPATH= cd -- "$assets" && pwd)
compiler="$assets/llvm-build/bin/clang"
test -x "$compiler"
test -d "$assets/sysroot/usr/include"
nice -n "${M88K_BUILD_NICE:-5}" cmake -S "$assets/llvm-m88k/runtimes" \
    -B "$assets/libcxx-build" -G Ninja -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_NAME=OpenBSD -DCMAKE_SYSTEM_PROCESSOR=m88k \
    -DCMAKE_C_COMPILER="$compiler" -DCMAKE_CXX_COMPILER="$compiler++" \
    -DCMAKE_C_COMPILER_TARGET=m88k-unknown-openbsd \
    -DCMAKE_CXX_COMPILER_TARGET=m88k-unknown-openbsd \
    -DCMAKE_SYSROOT="$assets/sysroot" \
    -DCMAKE_C_FLAGS='-fno-pic -fno-pie' \
    -DCMAKE_CXX_FLAGS='-fno-pic -fno-pie -fsjlj-exceptions -ftrap-function=abort -mllvm -verify-machineinstrs' \
    -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
    -DLLVM_ENABLE_RUNTIMES='libcxx;libcxxabi' -DLIBCXX_CXX_ABI=libcxxabi \
    -DLIBCXXABI_USE_LLVM_UNWINDER=OFF \
    -DLIBCXXABI_ENABLE_SHARED=OFF -DLIBCXXABI_ENABLE_STATIC=ON \
    -DLIBCXXABI_INCLUDE_TESTS=OFF \
    -DLIBCXX_ENABLE_SHARED=OFF -DLIBCXX_ENABLE_STATIC=ON \
    -DLIBCXX_INCLUDE_TESTS=OFF -DLIBCXX_INCLUDE_BENCHMARKS=OFF
nice -n "${M88K_BUILD_NICE:-5}" cmake --build "$assets/libcxx-build" \
    --target cxx_static cxxabi_static -j "${M88K_BUILD_JOBS:-2}"
