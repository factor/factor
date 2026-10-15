#!/usr/bin/env bash
# Usage: sparc-callback-probe.sh HOST_FACTOR HOST_IMAGE [NATIVE_HELPER_SOURCE]
# Execute the actual callback stub with native integer and floating arguments.
set -euo pipefail
probe_root=$(cd "$(dirname "$0")/../.." && pwd)
probe_helper=${3:-"$probe_root/vm/cpu-sparc-trampoline.S"}
probe_dir=$(mktemp -d)
trap 'rm -rf "$probe_dir"' EXIT
for probe_bits in 32 64; do
  "$1" -i="$2" -resource-path="$probe_root" -no-monitors \
    "$probe_root/misc/qemu/sparc-callback-probe.factor" "$probe_bits" "$probe_dir/"
  python3 "$probe_root/misc/qemu/sparc-callback-header.py" "$probe_dir"
  probe_flags=()
  probe_qemu=qemu-sparc64
  if [[ $probe_bits = 32 ]]; then
    probe_flags=(-m32)
    probe_qemu=qemu-sparc32plus
  fi
  sparc64-linux-gnu-gcc "${probe_flags[@]}" -static \
    -ffixed-g2 -ffixed-g3 -ffixed-g4 -ffixed-g5 -I"$probe_dir" \
    "$probe_root/misc/qemu/sparc-callback-probe.c" \
    "$probe_root/misc/qemu/sparc-callback-probe.S" "$probe_helper" \
    "$probe_root/vm/sparc-stackghost.cpp" -lm \
    -o "$probe_dir/callback-probe"
  "$probe_qemu" "$probe_dir/callback-probe"
done
