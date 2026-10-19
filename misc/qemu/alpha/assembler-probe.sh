#!/bin/bash
set -euo pipefail
root=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
host_factor=${1:?usage: assembler-probe.sh /absolute/host/factor /absolute/host/factor.image}
host_image=${2:?host Factor image required}
build=${ALPHA_PROBE_BUILD:-"$root/build-alpha"}
mkdir -p "$build"
cd "$build"
"$host_factor" -i="$host_image" -resource-path="$root" -no-monitors \
  "$root/misc/qemu/alpha/assembler-probe.factor"
alpha-linux-gnu-as -mev67 "$root/misc/qemu/alpha/assembler-reference.S" -o assembler-reference.o
alpha-linux-gnu-objcopy -O binary -j .text assembler-reference.o assembler-reference.bin
cmp alpha-assembler.bin assembler-reference.bin
printf 'Alpha integer and IEEE floating-point encodings match GNU assembler\n'
