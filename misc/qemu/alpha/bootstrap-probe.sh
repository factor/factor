#!/bin/bash
set -euo pipefail
root=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
host_factor=${1:?usage: bootstrap-probe.sh /absolute/host/factor /absolute/host/factor.image}
host_image=${2:?host Factor image required}
build=${ALPHA_PROBE_BUILD:-"$root/build-alpha"}
mkdir -p "$build"
cd "$build"
"$host_factor" -i="$host_image" -resource-path="$root" -no-monitors \
  "$root/misc/qemu/alpha/bootstrap-probe.factor"
alpha-linux-gnu-g++ -O2 -mieee "$root/vm/tests/alpha-bootstrap.cpp" \
  "$root/vm/tests/alpha-bootstrap-enter.S" -o alpha-bootstrap
: > alpha-word-call.bin
: > alpha-word-jump.bin
"$host_factor" -i="$host_image" -resource-path="$root" -no-monitors \
  "$root/misc/qemu/alpha/backend-probe.factor"
test -s alpha-word-call.bin
test -s alpha-word-jump.bin
qemu-alpha -L "${ALPHA_SYSROOT:-/usr/alpha-linux-gnu}" ./alpha-bootstrap
