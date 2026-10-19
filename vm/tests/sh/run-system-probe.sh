#!/usr/bin/env bash
# Run the native ABI and VM-layout probes inside a real Linux SH4 kernel.
# Supply the Debian SH4 vmlinuz and a statically linked SH4 BusyBox.
set -euo pipefail
repo=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
: "${SH_KERNEL:?set SH_KERNEL to the SH7751R vmlinuz}"
: "${SH_BUSYBOX:?set SH_BUSYBOX to a static SH4 BusyBox}"
probe_dir=$(mktemp -d)
trap 'rm -r -- "$probe_dir"' EXIT
mkdir -p "$probe_dir/root"/{bin,dev,proc,sys}
cp -- "$SH_BUSYBOX" "$probe_dir/root/bin/busybox"
ln -s busybox "$probe_dir/root/bin/sh"
"${SH_CXX:-sh4-linux-gnu-g++}" -std=c++17 -O2 -m4 -Wa,--isa=sh4 -static \
  "$repo/vm/tests/sh/native-probe.cpp" "$repo/vm/tests/sh/native-bridge.S" \
  -o "$probe_dir/root/bin/native-probe"
"${SH_CXX:-sh4-linux-gnu-g++}" -std=c++17 -O2 -m4 -Wa,--isa=sh4 -static \
  "$repo/vm/tests/layout-probe.cpp" -o "$probe_dir/root/bin/layout-probe"
cat > "$probe_dir/root/init" <<'INIT'
#!/bin/sh
/bin/busybox mount -t proc proc /proc
/bin/busybox mount -t sysfs sysfs /sys
/bin/busybox mount -t devtmpfs devtmpfs /dev
/bin/busybox uname -a
/bin/busybox cat /proc/cpuinfo
/bin/native-probe
probe_status=$?
/bin/layout-probe
layout_status=$?
echo "SH4-SYSTEM-NATIVE-PROBE: native=$probe_status layout=$layout_status"
/bin/busybox poweroff -f
while :; do /bin/busybox sleep 1; done
INIT
chmod +x "$probe_dir/root/init"
(cd "$probe_dir/root"; find . -print0 | cpio --null -o --format=newc 2>/dev/null) \
  | gzip -1 > "$probe_dir/initrd.gz"
python3 - "$SH_KERNEL" "$probe_dir" <<'PY'
from pathlib import Path
import sys, zlib
kernel = Path(sys.argv[1]).read_bytes()
start = kernel.find(b'\x1f\x8b\x08')
if start < 0:
    raise SystemExit('SH kernel gzip payload not found')
stream = zlib.decompressobj(31)
image = stream.decompress(kernel[start:])
if not stream.eof:
    raise SystemExit('Truncated kernel gzip payload')
# Large modern kernels overwrite the SH decompressor linked at +8 MiB.
# Load the unmodified Image directly. The -kernel tail initializes board
# registers and boot parameters; the generic loader fills the prefix.
cut = 0x0c800000 - 0x0c011000
if not cut < len(image) < 0x1800000 - 0x11000:
    raise SystemExit('Unexpected SH kernel size/layout')
out = Path(sys.argv[2])
(out / 'prefix').write_bytes(image[:cut])
(out / 'tail').write_bytes(image[cut:])
PY
"${SH_SYSTEM_QEMU:-qemu-system-sh4}" --version | head -1
# R2D hardware has a fixed 64 MiB RAM bank; changing -m cannot enlarge it.
timeout 45 "${SH_SYSTEM_QEMU:-qemu-system-sh4}" -M r2d -display none \
  -serial null -serial stdio -monitor none \
  -kernel "$probe_dir/tail" -initrd "$probe_dir/initrd.gz" \
  -device "loader,file=$probe_dir/prefix,addr=0x0c011000,force-raw=on" \
  -device loader,addr=0xac011000,cpu-num=0 > "$probe_dir/console.log" 2>&1
cat "$probe_dir/console.log"
rg -q 'SH4-SYSTEM-NATIVE-PROBE: native=0 layout=0' "$probe_dir/console.log"
