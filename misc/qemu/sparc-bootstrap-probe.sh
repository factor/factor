#!/usr/bin/env bash
# Usage: sparc-bootstrap-probe.sh /absolute/host/factor /absolute/host/factor.image
set -euo pipefail
probe_root=$(cd "$(dirname "$0")/../.." && pwd)
probe_dir=$(mktemp -d)
trap 'rm -rf "$probe_dir"' EXIT
for probe_bits in 32 64; do
  "$1" -i="$2" -resource-path="$probe_root" -no-monitors \
    "$probe_root/misc/qemu/sparc-bootstrap-probe.factor" "$probe_bits" "$probe_dir/"
  probe_flags=()
  probe_qemu=qemu-sparc64
  if [[ $probe_bits = 32 ]]; then
    probe_flags=(-m32)
    probe_qemu=qemu-sparc32plus
  fi
  sparc64-linux-gnu-gcc "${probe_flags[@]}" -static -ffixed-g2 -ffixed-g3 -ffixed-g4 -ffixed-g5 \
    -Wa,-I,"$probe_dir" "$probe_root/misc/qemu/sparc-bootstrap-probe.c" \
    "$probe_root/misc/qemu/sparc-bootstrap-probe.S" -lm -o "$probe_dir/probe"
  "$probe_qemu" "$probe_dir/probe"
done
