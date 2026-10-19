#!/usr/bin/env bash
# Zig frontend + LLVM ELFv1 codegen for snapshots whose PPC64 module flag is ELFv2.
set -euo pipefail
if [[ $# -lt 1 ]]; then
    echo "usage: $0 OUTPUT_DIRECTORY [zig build arguments]" >&2
    exit 2
fi
output_dir=$(realpath -m "$1")
shift
source_dir=$(cd "$(dirname "$0")/../.." && pwd)
zig_binary=${ZIG_BINARY:-zig}
llvm_clang=${LLVM_CLANG:-clang-21}
ppc64_gcc=${PPC64_GCC:-powerpc64-linux-gnu-gcc}
mkdir -p "$output_dir"
cd "$source_dir"
export ZIG_GLOBAL_CACHE_DIR=${ZIG_GLOBAL_CACHE_DIR:-$output_dir/global-cache}
"$zig_binary" build powerpc64-elfv1-ir -Dtarget=powerpc64-linux-gnu -Dcopy-to-root=false --cache-dir "$output_dir/cache" --prefix "$output_dir/frontend" "$@"
zig_lib_dir=$("$zig_binary" env | python3 -c 'import json,re,sys; text=sys.stdin.read(); match=re.search(r"(?:\.lib_dir|\"lib_dir\")\s*[:=]\s*(\"(?:[^\"\\]|\\.)*\")",text); print(json.loads(match[1]))')
"$zig_binary" build-obj "$zig_lib_dir/compiler_rt.zig" -target powerpc64-linux-gnu -OReleaseFast -femit-llvm-ir="$output_dir/compiler-rt.ll" -fno-emit-bin --cache-dir "$output_dir/cache"
python3 - "$output_dir" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
for name in ('factor', 'tests', 'compiler-rt'):
    source = root / (name + '.ll') if name == 'compiler-rt' else root / 'frontend/powerpc64-elfv1' / (name + '.ll')
    ir = source.read_text()
    # Preserve explicit ELFv1 IR if the Zig compiler already emits it correctly.
    assert re.search(r'!"target-abi", !"elfv[12]"', ir), 'missing PowerPC target ABI module flag'
    ir = ir.replace('!"target-abi", !"elfv2"', '!"target-abi", !"elfv1"')
    # LLVM 22 IR -> LLVM 21: these effect attributes are optimization hints.
    ir = ir.replace(' nocreateundeforpoison', '').replace(', target_mem0: none', '').replace(', target_mem1: none', '')
    # LLVM 22 removed the lifetime size operand. Unknown size (-1) is legal in 21.
    for kind in ('start', 'end'):
        intrinsic = '@llvm.lifetime.' + kind + '.p0('
        ir = ir.replace(intrinsic + 'ptr', intrinsic + 'i64 -1, ptr')
        ir = ir.replace('declare void ' + intrinsic + 'i64 -1, ptr', 'declare void ' + intrinsic + 'i64 immarg, ptr')
    if name == 'compiler-rt':
        # LLVM 22 can fold compiler_rt's copy loop back to llvm.memcpy.
        # Resolve memory routines through the linked GNU libc instead of the
        # resulting self-recursive weak hidden compiler_rt implementations.
        ir = re.sub(r'^@(memcpy|memmove|memset|memcmp|bcmp) = .*\n', '', ir, flags=re.M)
    (root / (name + '-elfv1.ll')).write_text(ir)
PY
for module in factor tests compiler-rt; do
    "$llvm_clang" -target powerpc64-linux-gnu -mabi=elfv1 -c "$output_dir/$module-elfv1.ll" -o "$output_dir/$module.o"
done
for module in factor tests; do
    "$ppc64_gcc" "$output_dir/$module.o" "$output_dir/compiler-rt.o" src/libc.c src/powerpc-context.c src/powerpc-abi.c -rdynamic -lm -pthread -o "$output_dir/$module.new"
    mv "$output_dir/$module.new" "$output_dir/$module"
done
printf 'ELFv1 Factor VM: %s\nELFv1 Zig unit tests: %s\n' "$output_dir/factor" "$output_dir/tests"
