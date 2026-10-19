#!/usr/bin/env bash
# Cross-build current OpenBSD VMs using headers and runtime libraries from a guest.
set -euo pipefail
task_arch=${1:?Use amd64, i386, or arm64}
task_assets=${OPENBSD_ASSETS:-"$PWD/work/qemu-matrix/openbsd"}
task_zig=${ZIG_EXE:-$(command -v zig)}
task_zig=$(realpath "$task_zig")
case "$task_arch" in
  amd64) task_target=x86_64; task_config=x86.64; task_port=22400 ;;
  i386) task_target=i386; task_config=x86.32; task_port=22401 ;;
  arm64) task_target=aarch64; task_config=arm.64; task_port=22402 ;;
  *) exit 2 ;;
esac
mkdir -p "$task_assets/$task_arch-sysroot" "$task_assets/toolchain"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p "$task_port" root@127.0.0.1 'tar czf - /usr/include /usr/lib/crt*.o /usr/lib/libc.so.* /usr/lib/libm.so.* /usr/lib/libpthread.so.* /usr/lib/libutil.so.* /usr/lib/libc++.so.* /usr/lib/libc++abi.so.* /usr/lib/libcompiler_rt.a' | tar xzf - -C "$task_assets/$task_arch-sysroot"
cat > "$task_assets/$task_arch-libc.conf" <<EOF
include_dir=$task_assets/$task_arch-sysroot/usr/include
sys_include_dir=$task_assets/$task_arch-sysroot/usr/include
crt_dir=$task_assets/$task_arch-sysroot/usr/lib
msvc_lib_dir=
kernel32_lib_dir=
cc_dir=
EOF
# OpenBSD std support in Zig dev2329 needs the checked-in compatibility patch.
if [[ ! -d "$task_assets/zig-lib" ]]; then
 cp -a "$(dirname "$task_zig")/lib" "$task_assets/zig-lib"
 patch -d "$task_assets/zig-lib" -p1 < misc/qemu/zig-openbsd-std.patch
fi
printf '#!/bin/sh\nexec %q ld.lld "$@"\n' "$task_zig" > "$task_assets/toolchain/ld.lld"
chmod +x "$task_assets/toolchain/ld.lld"
task_cc="clang-21 --target=$task_target-openbsd --sysroot=$task_assets/$task_arch-sysroot -B$task_assets/toolchain -fuse-ld=lld"
task_cxx="clang++-21 --target=$task_target-openbsd --sysroot=$task_assets/$task_arch-sysroot -stdlib=libc++ -isystem $task_assets/$task_arch-sysroot/usr/include/c++/v1 -B$task_assets/toolchain -fuse-ld=lld"
make -j8 factor factor-ffi-test CONFIG="vm/Config.openbsd.$task_config" BUILD_DIR="$task_assets/$task_arch-cpp-cross" RETGUARD_FLAGS= FFI_TEST_CFLAGS='-fPIC -DFACTOR_TEST_SMALL_FLOATS=0' CC="$task_cc" CXX="$task_cxx"
cp factor "$task_assets/$task_arch-factor-cpp"
cp libfactor-ffi-test.so "$task_assets/$task_arch-libfactor-ffi-test.so"
task_zig_arch=$task_target
[[ "$task_target" == i386 ]] && task_zig_arch=x86
ZIG_LIB_DIR="$task_assets/zig-lib" "$task_zig" build -Dtarget="$task_zig_arch-openbsd" -Doptimize=ReleaseFast -Dcopy-to-root=false -Dlibc-file="$task_assets/$task_arch-libc.conf" --prefix "$task_assets/$task_arch-zig"
python3 misc/qemu/openbsd-wxneeded.py "$task_assets/$task_arch-zig/bin/factor"
