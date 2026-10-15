#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
probe_dir=$(mktemp -d)
trap 'rm -rf -- "$probe_dir"' EXIT
for byte_order in little big; do
  if [[ $byte_order == little ]]; then
    flags=-ml
    link_flags=()
    emulator=${SH_QEMU:-qemu-sh4}
  else
    flags=-mb
    # Debian cross ld contains both BFD formats but only the LE emulation.
    link_flags=(-Wl,-m,shlelf_linux,--oformat,elf32-shbig-linux)
    emulator=${SH_QEMU_EB:-qemu-sh4eb}
  fi
  "${SH_CXX:-sh4-linux-gnu-g++}" -std=c++17 -O2 -m4 -Wa,--isa=sh4 "$flags" \
    -fno-pic -fno-pie -fno-exceptions -fno-rtti -nostdlib -no-pie \
    "${link_flags[@]}" -Wl,-e,_start "$repo/vm/tests/sh/freestanding.cpp" \
    "$repo/vm/tests/sh/freestanding-validate.cpp" \
    "$repo/vm/tests/sh/freestanding-start.S" -o "$probe_dir/sh-$byte_order"
  "$emulator" "$probe_dir/sh-$byte_order"
  printf 'Classic SH4 %s-endian freestanding code and call-layout probe passed\n' "$byte_order"
done
