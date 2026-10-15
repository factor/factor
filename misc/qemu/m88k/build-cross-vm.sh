#!/bin/sh
# Requires the pinned patched compiler and configured libcxx-build runtime tree.
# This builds the VM dependency subset, not the complete libc++ library.
set -eu
assets=${M88K_ASSETS:-"$PWD/work/qemu-matrix/m88k"}
assets=$(CDPATH= cd -- "$assets" && pwd)
out=${M88K_OUT:-"$assets/vm-native"}
mkdir -p "$out/objects"
compiler="$assets/llvm-build/bin/clang++"
for name in aging_collector alien arrays bignum byte_arrays callbacks callstack code_blocks code_heap compaction contexts data_heap data_heap_checker debug dispatch entry_points errors factor full_collector gc image inline_cache instruction_operands io jit math mvm nursery_collector object_start_map objects primitives quotations run safepoints sampling_profiler strings to_tenured_collector tuples utilities vm words zstd cpu-m88k os-unix os-openbsd os-genunix mvm-unix main-unix; do
    nice -n "${M88K_BUILD_NICE:-5}" "$compiler" --target=m88k-unknown-openbsd \
        -std=c++17 -O2 -fno-pic -fno-pie -fsjlj-exceptions \
        --sysroot="$assets/sysroot" -nostdinc++ \
        -isystem "$assets/libcxx-build/include/c++/v1" \
        -mllvm -verify-machineinstrs -c "vm/$name.cpp" -o "$out/objects/$name.o"
done
python3 misc/qemu/m88k/build-cross-runtime.py "$assets" "$out"
cp vm/cpu-m88k-trampoline.S misc/qemu/m88k/locked-atomics.c misc/qemu/m88k/link-native-vm.sh "$out/"
(cd "$out" && sha256sum objects/*.o libcxx-vm.a libc++abi.a cpu-m88k-trampoline.S locked-atomics.c > inputs.sha256)
printf '%s\n' "Transfer $out to the guest and run sh link-native-vm.sh there."
