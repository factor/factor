#!/bin/sh
set -eu

openssl_version=3.5.9
openssl_archive=openssl-$openssl_version.tar.gz
openssl_url=https://www.openssl.org/source/$openssl_archive
openssl_sha256=603f5602e2eef00d77fbd429d34dcd5822bb301757a1bc9cdb24c670f1eb859a

sqlite_version=3540000
sqlite_archive=sqlite-amalgamation-$sqlite_version.zip
sqlite_url=https://www.sqlite.org/2026/$sqlite_archive
sqlite_sha256=68e913b0fe8ec6b4e5f391c594a28872884e80d6cd042a1e50c957be46b5aa4d

: "${ANDROID_ABI:?set ANDROID_ABI to arm64-v8a or x86_64}"
: "${ANDROID_NDK_ROOT:?set ANDROID_NDK_ROOT to Android NDK r30}"

case $ANDROID_ABI in
    arm64-v8a)
        openssl_target=android-arm64
        compiler=aarch64-linux-android21-clang
        openssl_extra=
        ;;
    x86_64)
        openssl_target=android-x86_64
        compiler=x86_64-linux-android21-clang
        # NDK r30 rejects OpenSSL's GNU property assembly syntax.
        openssl_extra=no-asm
        ;;
    *)
        echo "unsupported Android ABI: $ANDROID_ABI" >&2
        exit 2
        ;;
esac

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(CDPATH= cd -- "$script_dir/../.." && pwd)
output_dir=${FACTOR_ANDROID_RUNTIME_LIBS_OUTPUT:-$repo_dir/android-libs}
case $output_dir in
    /*) ;;
    *) output_dir=$PWD/$output_dir ;;
esac
case $output_dir in
    ''|/|"$repo_dir")
        echo "unsafe Android runtime library output directory: $output_dir" >&2
        exit 2
        ;;
esac

work_dir=$(mktemp -d "${TMPDIR:-/tmp}/factor-android-libs.XXXXXX")
trap 'rm -rf "$work_dir"' EXIT HUP INT TERM

fetch() {
    name=$1
    url=$2
    expected=$3
    supplied=$4
    if test -n "$supplied"; then
        cp "$supplied" "$work_dir/$name"
    else
        curl --fail --location --retry 3 --output "$work_dir/$name" "$url"
    fi
    printf '%s  %s\n' "$expected" "$work_dir/$name" | sha256sum -c -
}

fetch "$openssl_archive" "$openssl_url" "$openssl_sha256" \
    "${OPENSSL_SOURCE_ARCHIVE:-}"
fetch "$sqlite_archive" "$sqlite_url" "$sqlite_sha256" \
    "${SQLITE_SOURCE_ARCHIVE:-}"

toolchain=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin
test -x "$toolchain/$compiler"
PATH=$toolchain:$PATH
export ANDROID_NDK_ROOT PATH

tar -C "$work_dir" -xzf "$work_dir/$openssl_archive"
mkdir "$work_dir/openssl-build"
cd "$work_dir/openssl-build"
"$work_dir/openssl-$openssl_version/Configure" "$openssl_target" \
    -D__ANDROID_API__=21 shared no-tests no-apps no-docs no-module \
    $openssl_extra
make -s -j"${ANDROID_DEPS_BUILD_JOBS:-8}" build_sw

cd "$work_dir"
unzip -q "$sqlite_archive"
"$toolchain/$compiler" -O2 -fPIC -shared -D_FILE_OFFSET_BITS=64 \
    -DSQLITE_THREADSAFE=1 -Wl,-soname,libsqlite3.so \
    -Wl,-z,max-page-size=16384 -Wl,-z,common-page-size=16384 \
    -o libsqlite3.so "sqlite-amalgamation-$sqlite_version/sqlite3.c" -ldl -lm

mkdir -p "$output_dir"
install -m 0755 openssl-build/libcrypto.so openssl-build/libssl.so \
    libsqlite3.so "$output_dir/"
