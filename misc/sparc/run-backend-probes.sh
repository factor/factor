#!/usr/bin/env bash
# Host Factor emits these instructions; QEMU executes those exact bytes.
set -euo pipefail
repo=$(cd -- "$(dirname -- "$0")/../.." && pwd)
factor_bin=${FACTOR_BIN:-$repo/factor}
factor_image=${FACTOR_IMAGE:-$repo/factor.image}
probe_dir=$(mktemp -d)
trap 'rm -rf "$probe_dir"' EXIT
for kind in integer ffi; do
    "$factor_bin" "-i=$factor_image" "-resource-path=$repo" -no-monitors "$repo/misc/sparc/backend-$kind-probe.factor" "$probe_dir"
    for width in 32 64; do
        flags=()
        emulator=qemu-sparc64
        if [[ $width == 32 ]]; then flags=(-m32); emulator=qemu-sparc32plus; fi
        extra_sources=()
        if [[ $kind == ffi ]]; then extra_sources=("${SPARC_TRAMPOLINE_SOURCE:-$repo/vm/cpu-sparc-trampoline.S}"); fi
        sparc64-linux-gnu-gcc -O2 -static "${flags[@]}" \
            -ffixed-g2 -ffixed-g3 -ffixed-g4 -ffixed-g5 \
            "$repo/misc/sparc/backend-$kind-probe.c" "${extra_sources[@]}" -o "$probe_dir/$kind-$width"
        if [[ $kind == integer ]]; then byte_file="$probe_dir/sparc-generated$width.bin"; else byte_file="$probe_dir/sparc-ffi-generated$width.bin"; fi
        "$emulator" "$probe_dir/$kind-$width" "$byte_file"
        if [[ $kind == integer ]]; then
            "$emulator" "$probe_dir/$kind-$width" "$probe_dir/sparc-pointer$width.bin"
            "$emulator" "$probe_dir/$kind-$width" "$probe_dir/sparc-large$width.bin"
        fi
    done
    if [[ $kind == ffi ]]; then
        qemu-sparc32plus "$probe_dir/ffi-32" "$probe_dir/sparc-sret-generated32.bin"
        qemu-sparc64 "$probe_dir/ffi-64" "$probe_dir/sparc-aggregate-generated64.bin"
    fi
done

"$factor_bin" "-i=$factor_image" "-resource-path=$repo" -no-monitors "$repo/misc/sparc/backend-compiler-probe.factor" "$probe_dir"
for width in 32 64; do
    flags=(); emulator=qemu-sparc64
    if [[ $width == 32 ]]; then flags=(-m32); emulator=qemu-sparc32plus; fi
    sparc64-linux-gnu-gcc -O2 -static "${flags[@]}" -ffixed-g2 -ffixed-g3 -ffixed-g4 -ffixed-g5 \
        "$repo/misc/sparc/backend-compiler-probe.c" "$repo/misc/sparc/backend-compiler-entry.S" "${SPARC_TRAMPOLINE_SOURCE:-$repo/vm/cpu-sparc-trampoline.S}" -o "$probe_dir/compiler-$width"
    for operation in add-fixnums min-fixnums multiply-fixnums get-slot add-floats call-native-add call-native-floats; do
        "$emulator" "$probe_dir/compiler-$width" "$probe_dir/$operation$width.bin"
    done
    if [[ $width == 64 ]]; then "$emulator" "$probe_dir/compiler-$width" "$probe_dir/call-native-union64.bin"; fi
done
