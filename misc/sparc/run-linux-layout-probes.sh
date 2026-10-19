#!/usr/bin/env bash
# Independent native GNU ABI measurements, not Factor compiler/io acceptance.
set -euo pipefail
repo=$(cd -- "$(dirname -- "$0")/../.." && pwd)
probe_dir=$(mktemp -d)
trap 'rm -rf "$probe_dir"' EXIT
for bits in 32 64; do
    sparc64-linux-gnu-gcc -m"$bits" -mcpu=v9 -static \
        "$repo/misc/sparc/linux-layout-probe.c" -o "$probe_dir/layout$bits"
    if [ "$bits" = 32 ]; then
        qemu-sparc32plus "$probe_dir/layout$bits"
    else
        qemu-sparc64 "$probe_dir/layout$bits"
    fi
done
