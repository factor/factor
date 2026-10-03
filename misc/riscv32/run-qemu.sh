#!/usr/bin/env bash
set -euo pipefail

# Usage: misc/riscv32/run-qemu.sh /path/to/rv32-output [EXTRA_QEMU_ARGS...]
# Install QEMU with `brew install qemu` or Debian's qemu-system-misc package.
# The first run copies the generated rootfs to a persistent development disk.
# Rebuilding Buildroot will not overwrite that disk or its saved Factor images.
# Optional RV32_QEMU, RV32_DISK, RV32_SSH_PORT, RV32_CPUS, RV32_MEMORY overrides.
# Console login: root. SSH needs the public key supplied to build.sh:
#   ssh -p 22232 -i /path/to/private-key root@127.0.0.1
#   scp -O -P 22232 -i /path/to/private-key file root@127.0.0.1:/root/
# Dropbear has legacy SCP; it does not provide an SFTP server.
# Power off inside Linux before reusing or replacing the development disk.

if [[ ${1:-} == -h || ${1:-} == --help ]]; then
    echo "Usage: $0 BUILDROOT_OUTPUT_DIR [EXTRA_QEMU_ARGS...]"
    exit 0
fi
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 BUILDROOT_OUTPUT_DIR [EXTRA_QEMU_ARGS...]" >&2
    exit 1
fi
output_dir=$(cd -- "$1" && pwd)
shift
qemu=${RV32_QEMU:-qemu-system-riscv32}
command -v "$qemu" >/dev/null
images="$output_dir/images"
disk=${RV32_DISK:-$output_dir/rootfs-factor-riscv32.ext4}
ssh_port=${RV32_SSH_PORT:-22232}
if [[ ! $ssh_port =~ ^[1-9][0-9]{0,4}$ ]] || (( ssh_port > 65535 )); then
    echo "RV32_SSH_PORT must be between 1 and 65535." >&2
    exit 1
fi
for image in Image fw_dynamic.bin rootfs.ext2; do
    if [[ ! -f $images/$image ]]; then
        echo "Missing Buildroot image: $images/$image" >&2
        exit 1
    fi
done
if [[ ! -e $disk ]]; then
    cp -- "$images/rootfs.ext2" "$disk"
fi

exec "$qemu" -M virt -cpu rv32 -smp "${RV32_CPUS:-2}" \
    -m "${RV32_MEMORY:-1024M}" -nographic \
    -bios "$images/fw_dynamic.bin" -kernel "$images/Image" \
    -drive "file=$disk,format=raw,id=root,if=none" \
    -device virtio-blk-device,drive=root -device virtio-rng-device \
    -netdev "user,id=net,hostfwd=tcp:127.0.0.1:$ssh_port-:22" \
    -device virtio-net-device,netdev=net \
    -append "console=ttyS0 rootwait root=/dev/vda rw" "$@"
