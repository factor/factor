#!/usr/bin/env bash
# Official Buildroot 2026.08 RV32 virt guest and cross C++ toolchain.
set -euo pipefail
asset_dir=${FACTOR_QEMU_RISCV_DIR:-${FACTOR_QEMU_MATRIX_DIR:-/home/sheeple/factor/work/qemu-matrix}/riscv-linux}
mkdir -p "$asset_dir"
cd "$asset_dir"
if [ ! -d buildroot-2026.08 ]; then
  curl -fL https://buildroot.org/downloads/buildroot-2026.08.tar.xz -o buildroot-2026.08.tar.xz
  tar -xf buildroot-2026.08.tar.xz
fi
if [ ! -f id_ed25519 ]; then ssh-keygen -q -t ed25519 -N '' -f id_ed25519; fi
mkdir -p overlay32/root/.ssh
cp id_ed25519.pub overlay32/root/.ssh/authorized_keys
chmod 700 overlay32/root/.ssh
chmod 600 overlay32/root/.ssh/authorized_keys
mkdir -p host-tools
# Ubuntu uutils install is rejected by Buildroot dependency checks.
if command -v gnuinstall >/dev/null; then ln -sf "$(command -v gnuinstall)" host-tools/install; fi
export PATH="$asset_dir/host-tools:$PATH"
cd buildroot-2026.08
if [ ! -f .config ]; then
  make qemu_riscv32_virt_defconfig
  sed -i '/^BR2_PACKAGE_HOST_QEMU/d' .config
  cat >> .config <<EOF
# BR2_PACKAGE_HOST_QEMU is not set
BR2_TOOLCHAIN_BUILDROOT_CXX=y
BR2_PACKAGE_DROPBEAR=y
BR2_PACKAGE_MAKE=y
BR2_PACKAGE_BINUTILS=y
BR2_PACKAGE_BUSYBOX_SHOW_OTHERS=y
BR2_PACKAGE_BASH=y
BR2_PACKAGE_FILE=y
BR2_PACKAGE_LIBFFI=y
BR2_PACKAGE_OPENSSL=y
BR2_PACKAGE_LIBOPENSSL=y
BR2_PACKAGE_LIBOPENSSL_BIN=y
BR2_PACKAGE_CA_CERTIFICATES=y
BR2_GENERATE_LOCALE="en_US.UTF-8"
BR2_PACKAGE_ZLIB=y
BR2_PACKAGE_ZSTD=y
BR2_PACKAGE_LIBCURL=y
BR2_PACKAGE_LIBCURL_CURL=y
BR2_PACKAGE_LIBYAML=y
BR2_PACKAGE_SQLITE=y
BR2_PACKAGE_LIBUV=y
BR2_PACKAGE_GMP=y
BR2_PACKAGE_GSL=y
BR2_PACKAGE_PCRE2=y
BR2_TARGET_ROOTFS_EXT2_SIZE="1024M"
BR2_ROOTFS_OVERLAY="$asset_dir/overlay32"
EOF
  make olddefconfig
fi
make -j"${FACTOR_QEMU_BUILD_JOBS:-8}"
