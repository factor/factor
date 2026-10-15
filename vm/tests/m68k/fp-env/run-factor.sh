#!/bin/bash
set -euo pipefail
: "${M68K_FACTOR_VM:?Set M68K_FACTOR_VM to a native M68k Factor binary}"
: "${M68K_FACTOR_IMAGE:?Set M68K_FACTOR_IMAGE to its matching image}"
probe_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
probe_source=$(cd -- "$probe_root/../../../.." && pwd)
# Factor defaults resource: to the image directory; select this checkout
# explicitly without changing the supplied VM or image.
probe_build=$(mktemp -d)
trap 'rm -rf "$probe_build"' EXIT
cp "$M68K_FACTOR_VM" "$probe_build/factor"
for probe_vocab_root in basis core extra misc work; do
    ln -s "$probe_source/$probe_vocab_root" "$probe_build/$probe_vocab_root"
done
QEMU_LD_PREFIX=${QEMU_LD_PREFIX:-/usr/m68k-linux-gnu} qemu-m68k -cpu m68040 "$probe_build/factor" -no-monitors -debug-compiler -resource-path="$probe_build" -i="$M68K_FACTOR_IMAGE" -roots="$probe_source/basis" "$probe_root/native.factor"
