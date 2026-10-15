#!/bin/bash
set -euo pipefail
probe_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
probe_build=$(mktemp -d)
trap 'rm -rf "$probe_build"' EXIT
m68k-linux-gnu-gcc -m68040 -O2 -static -Wall -Wextra "$probe_root/native.c" -o "$probe_build/native"
qemu-m68k -cpu m68040 "$probe_build/native"
