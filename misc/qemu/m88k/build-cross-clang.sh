#!/bin/sh
# Build an experimental compiler; success here is not a Factor VM milestone.
set -eu
assets=${M88K_ASSETS:-"$PWD/work/qemu-matrix/m88k"}
revision=736e78ed53b1f57eb1b5d125119cb9ea3ac9978d
mkdir -p "$assets"
if test ! -d "$assets/llvm-m88k/.git"; then
    git clone --depth 1 --single-branch --branch main-m88k \
        https://github.com/redstar/llvm-m88k.git "$assets/llvm-m88k"
fi
if test "$(git -C "$assets/llvm-m88k" rev-parse HEAD)" != "$revision"; then
    git -C "$assets/llvm-m88k" fetch --depth 1 origin "$revision"
    git -C "$assets/llvm-m88k" checkout --detach "$revision"
fi
patches=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
patch_file="$patches/clang-factor.patch"
if git -C "$assets/llvm-m88k" apply --reverse --check "$patch_file" >/dev/null 2>&1; then
    : # Already applied.
else
    git -C "$assets/llvm-m88k" apply --check "$patch_file"
    git -C "$assets/llvm-m88k" apply "$patch_file"
fi
cmake -S "$assets/llvm-m88k/llvm" -B "$assets/llvm-build" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER="${HOST_CC:-clang-21}" \
    -DCMAKE_CXX_COMPILER="${HOST_CXX:-clang++-21}" \
    -DLLVM_ENABLE_PROJECTS=clang -DLLVM_TARGETS_TO_BUILD= \
    -DCLANG_ENABLE_STATIC_ANALYZER=OFF -DCLANG_ENABLE_ARCMT=OFF \
    -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=M88k \
    -DLLVM_INCLUDE_TESTS=OFF -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_ENABLE_TERMINFO=OFF -DLLVM_ENABLE_ZSTD=OFF \
    -DLLVM_ENABLE_ZLIB=OFF -DLLVM_ENABLE_LIBXML2=OFF \
    -DLLVM_PARALLEL_LINK_JOBS=1
nice -n "${M88K_BUILD_NICE:-5}" cmake --build "$assets/llvm-build" --target clang llvm-mc llvm-objdump \
    -j "${M88K_BUILD_JOBS:-2}"
