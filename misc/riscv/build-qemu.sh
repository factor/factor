#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == -h || ${1:-} == --help ]]; then
    cat <<'EOF'
Usage: build-qemu.sh [OUTPUT_DIR]

Build static RV32 and RV64 QEMU user interpreters on Linux. QEMU 10.0.13
is pinned with a correction for Linux ioctl error precedence on invalid
descriptors. This preserves the native EBADF tests without changing Factor.

Debian builder dependencies:
  sudo apt-get install build-essential curl xz-utils patch python3-venv \
      libglib2.0-dev zlib1g-dev pkg-config ninja-build

OUTPUT_DIR defaults to build/riscv-qemu-tools. QEMU_BUILD_JOBS sets parallelism.
Pass OUTPUT_DIR/bin/qemu-riscv32 or qemu-riscv64 to test-qemu.sh --qemu.
EOF
    exit 0
fi
[[ $# -le 1 ]] || { echo 'Usage: build-qemu.sh [OUTPUT_DIR]' >&2; exit 2; }
[[ $(uname -s) == Linux ]] || { echo 'Build QEMU on Linux.' >&2; exit 1; }
for command in curl tar patch sha256sum python3 pkg-config ninja cc getconf realpath file; do
    command -v "$command" >/dev/null || { echo "Missing command: $command" >&2; exit 1; }
done
pkg-config --exists glib-2.0 || { echo 'Install libglib2.0-dev on the builder.' >&2; exit 1; }

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
output=${1:-build/riscv-qemu-tools}
mkdir -p -- "$output"
output=$(realpath -e -- "$output")
version=10.0.13
archive="$output/qemu-$version.tar.xz"
checksum=4a59b74dac7ead8b162a7c4595dcbbeebe989b90c89cfe6bb4dec5447342f6fa
source_dir="$output/qemu-$version"
build_dir="$output/build"
patch_file="$script_dir/qemu-ioctl-bad-fd.patch"

if [[ ! -f $archive ]]; then
    curl -fL --retry 3 "https://download.qemu.org/qemu-$version.tar.xz" -o "$archive.part"
    mv -- "$archive.part" "$archive"
fi
printf '%s  %s\n' "$checksum" "$archive" | sha256sum -c -
if [[ ! -f $source_dir/.factor-source-ready ]]; then
    tar -xJf "$archive" -C "$output"
    touch "$source_dir/.factor-source-ready"
fi
if patch --batch --forward --silent --dry-run -p1 -d "$source_dir" < "$patch_file"; then
    patch --batch --forward -p1 -d "$source_dir" < "$patch_file"
elif ! patch --batch --silent --dry-run --reverse -p1 -d "$source_dir" < "$patch_file"; then
    echo 'The QEMU source does not match the pinned ioctl correction.' >&2
    exit 1
fi

mkdir -p -- "$build_dir" "$output/bin"
(
    cd -- "$build_dir"
    "$source_dir/configure" --target-list=riscv32-linux-user,riscv64-linux-user \
        --static --without-default-features --disable-system --disable-tools \
        --disable-docs --disable-guest-agent --disable-debug-info --disable-werror
)
ninja -C "$build_dir" -j "${QEMU_BUILD_JOBS:-$(getconf _NPROCESSORS_ONLN)}" \
    qemu-riscv32 qemu-riscv64
for bits in 32 64; do
    binary="$build_dir/qemu-riscv$bits"
    case $(LC_ALL=C file -L "$binary") in
        *'statically linked'*|*'static-pie linked'*) ;;
        *) echo "Expected a static QEMU interpreter: $binary" >&2; exit 1 ;;
    esac
    install -m 755 -- "$binary" "$output/bin/qemu-riscv$bits.new"
    mv -- "$output/bin/qemu-riscv$bits.new" "$output/bin/qemu-riscv$bits"
done
sha256sum "$archive" "$patch_file" "$output/bin/qemu-riscv32" \
    "$output/bin/qemu-riscv64" > "$output/sha256sums.txt"
"$output/bin/qemu-riscv64" --version > "$output/version.txt"
echo "Static QEMU interpreters: $output/bin/qemu-riscv32 and qemu-riscv64"
