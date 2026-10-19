#!/usr/bin/env bash
# Usage: run-callback-entry-poll-probe.sh HOST_FACTOR HOST_IMAGE [OUTPUT]
set -euo pipefail
probe_root=$(cd -- "$(dirname -- "$0")/../.." && pwd)
probe_output=${3:-"$probe_root/artifacts/callback-entry-poll"}
mkdir -p "$probe_output"
probe_output=$(cd -- "$probe_output" && pwd)
"$1" -i="$2" -resource-path="$probe_root" -no-monitors \
  "$probe_root/misc/sparc/callback-entry-poll-probe.factor" "$probe_output"
for width in 32 64; do
  flags=(); emulator=qemu-sparc64
  if [[ $width == 32 ]]; then flags=(-m32 -mcpu=v9); emulator=qemu-sparc32plus; fi
  sparc64-linux-gnu-gcc -O2 -static "${flags[@]}" \
    "$probe_root/misc/sparc/callback-entry-poll-probe.c" -o "$probe_output/probe$width"
  "$emulator" "$probe_output/probe$width" \
    "$probe_output/entry$width.bin" "$probe_output/entry$width.reloc"
done
