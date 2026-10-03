#!/usr/bin/env bash
set -euo pipefail

# Run on a Linux builder, including native ARM64 Linux on an ARM64 Mac.
# Debian prerequisites:
# sudo apt-get install build-essential bc bison flex libssl-dev libelf-dev \
#   libncurses-dev rsync cpio unzip wget curl file python3
# curl -fLO https://buildroot.org/downloads/buildroot-2026.08.tar.xz
# tar -xf buildroot-2026.08.tar.xz
# misc/riscv32/build.sh ./buildroot-2026.08 ./rv32-output
# Optional: RV32_SSH_PUBLIC_KEY=/path/to/key.pub provisions root key-based SSH.
# The generated config replaces the selected output directory's configuration.

usage() {
    echo "Usage: $0 BUILDROOT_2026.08_DIR [OUTPUT_DIR]"
}

if [[ ${1:-} == -h || ${1:-} == --help ]]; then usage; exit 0; fi
if [[ $# -lt 1 || $# -gt 2 ]]; then usage >&2; exit 1; fi
if [[ $(uname -s) != Linux ]]; then
    echo "Buildroot requires a Linux builder." >&2
    exit 1
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
buildroot_dir=$(cd -- "$1" && pwd)
version=$(sed -n 's/^export BR2_VERSION := //p' "$buildroot_dir/Makefile")
if [[ $version != 2026.08 ]]; then
    echo "Expected Buildroot 2026.08; found ${version:-unknown}." >&2
    exit 1
fi
mkdir -p -- "${2:-$buildroot_dir/output-factor-riscv32}"
output_dir=$(cd -- "${2:-$buildroot_dir/output-factor-riscv32}" && pwd)
config="$output_dir/factor-riscv32_defconfig"
cp -- "$script_dir/buildroot_defconfig" "$config"
post_build_script="$script_dir/provision.sh"
quoted_script=${post_build_script//\\/\\\\}
quoted_script=${quoted_script//\"/\\\"}
printf 'BR2_ROOTFS_POST_BUILD_SCRIPT="%s"\n' "$quoted_script" >> "$config"

if [[ -n ${RV32_SSH_PUBLIC_KEY:-} ]]; then
    overlay="$output_dir/ssh-overlay"
    mkdir -p -- "$overlay/root/.ssh"
    cat -- "$RV32_SSH_PUBLIC_KEY" > "$overlay/root/.ssh/authorized_keys"
    chmod 700 "$overlay/root/.ssh"
    chmod 600 "$overlay/root/.ssh/authorized_keys"
    quoted_overlay=${overlay//\\/\\\\}
    quoted_overlay=${quoted_overlay//\"/\\\"}
    printf 'BR2_ROOTFS_OVERLAY="%s"\n' "$quoted_overlay" >> "$config"
fi

make -C "$buildroot_dir" O="$output_dir" BR2_DEFCONFIG="$config" defconfig
make -C "$buildroot_dir" O="$output_dir" -j4

# tools.disassembler needs Capstone; Buildroot 2026.08 has no package for it.
# Build every upstream architecture, including RISC-V and compressed decoding.
vendor="$output_dir/vendor"
mkdir -p -- "$vendor"
archive="$vendor/capstone-5.0.9.tar.gz"
if [[ ! -f $archive ]]; then
    curl -fL https://github.com/capstone-engine/capstone/archive/refs/tags/5.0.9.tar.gz \
        -o "$archive.download"
    mv -- "$archive.download" "$archive"
fi
printf '%s  %s\n' \
    0619da31af08152600af95c481527ef6d756c0a8404fca7544a4fdf6dfc2c0f9 "$archive" \
    | sha256sum -c -
tar -xf "$archive" -C "$vendor"
capstone="$vendor/capstone-5.0.9"
cross="$output_dir/host/bin/riscv32-buildroot-linux-gnu-"
make -C "$capstone" clean
make -C "$capstone" -j4 CROSS="$cross" CAPSTONE_BUILD_STATIC= \
    CAPSTONE_BUILD_SHARED=yes CAPSTONE_BUILD_CORE_ONLY=yes
install -m755 "$capstone/libcapstone.so.5" "$output_dir/target/usr/lib/"
ln -sf libcapstone.so.5 "$output_dir/target/usr/lib/libcapstone.so"

# The legacy pcre vocabulary uses PCRE1, which Buildroot no longer packages.
pcre_archive="$vendor/pcre-8.45.tar.bz2"
if [[ ! -f $pcre_archive ]]; then
    curl -fL https://downloads.sourceforge.net/project/pcre/pcre/8.45/pcre-8.45.tar.bz2 \
        -o "$pcre_archive.download"
    mv -- "$pcre_archive.download" "$pcre_archive"
fi
printf '%s  %s\n' \
    4dae6fdcd2bb0bb6c37b5f97c33c2be954da743985369cddac3546e3218bffb8 "$pcre_archive" \
    | sha256sum -c -
tar -xf "$pcre_archive" -C "$vendor"
pcre="$vendor/pcre-8.45"
(
    cd -- "$pcre"
    CC="${cross}gcc" ./configure --host=riscv32-buildroot-linux-gnu \
        --prefix=/usr --enable-shared --disable-static --disable-cpp \
        --enable-utf --enable-unicode-properties
    make -j4 libpcre.la
)
install -m755 "$pcre/.libs/libpcre.so.1.2.13" "$output_dir/target/usr/lib/"
ln -sf libpcre.so.1.2.13 "$output_dir/target/usr/lib/libpcre.so.1"
ln -sf libpcre.so.1.2.13 "$output_dir/target/usr/lib/libpcre.so"

# BLIS provides portable BLAS kernels and GNU-compatible Fortran entry points.
# Its generic C backend works with ILP32D without a target Fortran compiler.
blas_archive="$vendor/blis-1.2.tar.gz"
if [[ ! -f $blas_archive ]]; then
    curl -fL https://github.com/flame/blis/archive/refs/tags/1.2.tar.gz \
        -o "$blas_archive.download"
    mv -- "$blas_archive.download" "$blas_archive"
fi
printf '%s  %s\n' \
    c36f2bd7580f1d30c2d81c5081b76da1058db888d303d7f5a3a41e0cb09bea94 "$blas_archive" \
    | sha256sum -c -
tar -xf "$blas_archive" -C "$vendor"
blas="$vendor/blis-1.2"
(
    cd -- "$blas"
    CC="${cross}gcc" AR="${cross}ar" RANLIB="${cross}ranlib" \
        ./configure --prefix=/usr --disable-static --enable-shared --enable-cblas \
        --int-size=32 --blas-int-size=32 --complex-return=gnu generic
    make -j4
)
install -m755 "$blas/lib/generic/libblis.so" "$output_dir/target/usr/lib/libblis.so.4"
ln -sf libblis.so.4 "$output_dir/target/usr/lib/libblis.so"
ln -sf libblis.so.4 "$output_dir/target/usr/lib/libblas.so.3"
ln -sf libblis.so.4 "$output_dir/target/usr/lib/libblas.so"
# Regenerate the filesystem after adding the cross-built runtime library.
make -C "$buildroot_dir" O="$output_dir" -j4
echo "RV32 images: $output_dir/images"
echo "Start with: $script_dir/run-qemu.sh $output_dir"
