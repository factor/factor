#!/usr/bin/env bash
set -euo pipefail
if [[ $# != 1 ]]; then
  echo "Usage: $0 HOST_FACTOR (executable rooted in this checkout)" >&2
  exit 2
fi
repo=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
probe_dir=$(mktemp -d /tmp/factor-m68k-bootstrap.XXXXXX)
trap 'rm -rf -- "$probe_dir"' EXIT
host_factor=$(realpath -- "$1")
host_image=$(dirname -- "$host_factor")/factor.image
"$host_factor" -i="$host_image" -resource-path="$repo" -q -no-user-init -no-monitors \
  -e="USING: namespaces parser ; \"$probe_dir/\" \"m68k-bootstrap-probe-dir\" set \"$repo/misc/qemu/m68k/bootstrap-emit.factor\" run-file"
m68k-linux-gnu-gcc -O2 -static -m68020 \
  -o "$probe_dir/probe" "$repo/misc/qemu/m68k/bootstrap-probe.c" \
  "$repo/misc/qemu/m68k/bootstrap-bridge.S"
qemu-m68k "$probe_dir/probe" "$probe_dir"
