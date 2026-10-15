#!/usr/bin/env bash
# Execute actual quotation JIT templates with a live caller spill.
# Usage: sparc-jit-entry-gc.sh HOST_FACTOR HOST_IMAGE [OUTPUT]
set -euo pipefail
probe_root=$(cd "$(dirname "$0")/../.." && pwd)
probe_output=${3:-$probe_root/artifacts/jit-entry-gc}
mkdir -p "$probe_output"/{32,64}
probe_output=$(cd "$probe_output" && pwd)
# Generate the caller with the CPU backend and compile the production visitor.
QEMU_USER=0 bash "$probe_root/misc/qemu/sparc-entry-gc.sh" "$1" "$2" "$probe_output"
for probe_bits in 32 64; do
  "$1" -i="$2" -resource-path="$probe_root" -no-monitors \
    "$probe_root/misc/qemu/sparc-callback-probe.factor" "$probe_bits" "$probe_output/$probe_bits/"
done
python3 - "$probe_output" <<'BUILD'
from pathlib import Path
import sys
base=Path(sys.argv[1])
for width in ('32','64'):
    out=base/width
    poll=(out/'safepoint.bin').read_bytes()
    prolog=(out/'prolog.bin').read_bytes()
    tail=(out/'epilog.bin').read_bytes()+(out/'return.bin').read_bytes()
    rel=(out/'safepoint.reloc').read_bytes()
    assert len(rel)==4 and len(prolog)==4
    record=int.from_bytes(rel,'big')
    (out/'before-jit.bin').write_bytes(poll+prolog+tail)
    (out/'before-jit.reloc').write_bytes(rel)
    (out/'after-jit.bin').write_bytes(prolog+poll+tail)
    (out/'after-jit.reloc').write_bytes((record+len(prolog)).to_bytes(4,'big'))
BUILD
for probe_bits in 32 64; do
  probe_qemu=qemu-sparc64
  if [[ $probe_bits = 32 ]]; then probe_qemu=qemu-sparc32plus; fi
  "$probe_qemu" "$probe_output/probe$probe_bits" "$probe_output/$probe_bits" before-jit
  "$probe_qemu" "$probe_output/probe$probe_bits" "$probe_output/$probe_bits" after-jit
  "$probe_qemu" "$probe_output/probe$probe_bits" "$probe_output/$probe_bits" after-jit zig
done
sha256sum "$probe_output"/probe{32,64} \
  "$probe_output"/{32,64}/{caller*,before-jit*,after-jit*,safepoint*,prolog.bin,epilog.bin,return.bin} \
  "$probe_root/vm/quotations.cpp" "$probe_root/vm/tests/sparc-entry-gc.cpp" \
  "$probe_root/vm/sparc-linux-signal.h" "$probe_root/basis/bootstrap/assembler/sparc.factor" \
  > "$probe_output/model-sha256.txt"
