#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "$0")/../.." && pwd)
probe_dir=$(mktemp -d)
trap 'rm -rf "$probe_dir"' EXIT
"${FACTOR_BIN:-$repo/factor}" "-i=${FACTOR_IMAGE:-$repo/factor.image}" \
    "-resource-path=${SPARC_BOOTSTRAP_RESOURCE:-$repo}" -no-monitors \
    "$repo/misc/sparc/backend-callback-probe.factor" "$probe_dir"
sparc64-linux-gnu-gcc -O2 -static -m32 -ffixed-g2 -ffixed-g3 -ffixed-g4 -ffixed-g5 \
    "$repo/misc/sparc/backend-callback-probe.c" "$repo/misc/sparc/backend-callback-entry.S" -o "$probe_dir/callback"
qemu-sparc32plus "$probe_dir/callback" "$probe_dir/callback32.bin" "$probe_dir/callback32.relocs"
