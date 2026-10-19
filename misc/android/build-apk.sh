#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/../.." && pwd)
: "${ANDROID_HOME:?set ANDROID_HOME to an Android SDK containing platform 35}"
: "${FACTOR_VM_ROOT:?set FACTOR_VM_ROOT to ABI subdirectories containing libfactor.so}"

resource_path=${FACTOR_RESOURCE_PATH:-$repo_dir}
assets_dir=$script_dir/app/src/main/assets
work_dir=${FACTOR_ANDROID_WORK_DIR:-$assets_dir}

test -f "$FACTOR_VM_ROOT/arm64-v8a/factor.image"
test -f "$FACTOR_VM_ROOT/x86_64/factor.image"
test -d "$resource_path/core"
test -d "$resource_path/basis"

install -d "$assets_dir"
install -d "$work_dir"
cli_root=$work_dir/jniLibs
for abi in arm64-v8a x86_64; do
    test -x "$FACTOR_VM_ROOT/$abi/factor"
    test -f "$FACTOR_VM_ROOT/$abi/android-libs/libcrypto.so"
    test -f "$FACTOR_VM_ROOT/$abi/android-libs/libssl.so"
    test -f "$FACTOR_VM_ROOT/$abi/android-libs/libsqlite3.so"
    install -d "$cli_root/$abi"
    install -m 0755 "$FACTOR_VM_ROOT/$abi/factor" \
        "$cli_root/$abi/libfactor-cli.so"
    install -m 0755 "$FACTOR_VM_ROOT/$abi/android-libs/libcrypto.so" \
        "$FACTOR_VM_ROOT/$abi/android-libs/libssl.so" \
        "$FACTOR_VM_ROOT/$abi/android-libs/libsqlite3.so" "$cli_root/$abi/"
done
install -m 0644 "$FACTOR_VM_ROOT/arm64-v8a/factor.image" \
    "$assets_dir/factor.arm64-v8a.image"
install -m 0644 "$FACTOR_VM_ROOT/x86_64/factor.image" \
    "$assets_dir/factor.x86_64.image"
resource_archive=$work_dir/factor-resources.tar
tar -C "$resource_path" -cf "$resource_archive" \
    basis core extra LICENSE.txt README.md
if test "$work_dir" != "$assets_dir"; then
    asset_archive=$assets_dir/factor-resources.tar
    if test -e "$asset_archive" || test -L "$asset_archive"; then
        unlink "$asset_archive"
    fi
    ln -s "$resource_archive" "$asset_archive"
fi

exec gradle --project-dir "$script_dir" \
    -PfactorVmRoot="$FACTOR_VM_ROOT" -PfactorCliRoot="$cli_root" \
    assembleDebug "$@"
