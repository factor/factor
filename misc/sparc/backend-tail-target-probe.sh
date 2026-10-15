#!/usr/bin/env bash
# Run normal compiler output under QEMU and check tail PIC site and parent window.
# Usage: backend-tail-target-probe.sh HOST_FACTOR HOST_IMAGE
set -euo pipefail
probe_root=$(cd "$(dirname "$0")/../.." && pwd)
probe_dir=$(mktemp -d)
trap 'rm -rf "$probe_dir"' EXIT
"$1" -i="$2" -resource-path="$probe_root" -no-user-init -no-monitors \
  "$probe_root/misc/sparc/backend-tail-target-probe.factor" "$probe_dir"
for probe_bits in 32 64; do
  probe_flags=()
  probe_qemu=qemu-sparc64
  if [[ $probe_bits = 32 ]]; then
    probe_flags=(-m32)
    probe_qemu=qemu-sparc32plus
  fi
  sparc64-linux-gnu-gcc "${probe_flags[@]}" -static -O2 \
    "$probe_root/misc/sparc/backend-tail-target-probe.c" \
    "$probe_root/misc/sparc/backend-tail-target-probe.S" -o "$probe_dir/probe"
  "$probe_qemu" "$probe_dir/probe" "$probe_dir/caller$probe_bits.bin"
  "$1" -i="$2" -resource-path="$probe_root" -no-user-init -no-monitors \
    "$probe_root/misc/qemu/sparc-context-probe.factor" "$probe_bits" "$probe_dir/"
  cat "$probe_dir/prolog.bin" "$probe_dir/epilog.bin" "$probe_dir/tail.bin" > "$probe_dir/jit-caller.bin"
  "$probe_qemu" "$probe_dir/probe" "$probe_dir/jit-caller.bin"
done
