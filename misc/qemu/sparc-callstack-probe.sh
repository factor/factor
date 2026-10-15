#!/usr/bin/env bash
# Usage: sparc-callstack-probe.sh HOST_FACTOR HOST_IMAGE [NATIVE_HELPER_SOURCE]
# Patches the real Factor RT_HERE/DLSYM records, then executes the emitted
# prologue, context transfer, synthetic resume, epilogue and return in QEMU.
set -euo pipefail
probe_root=$(cd "$(dirname "$0")/../.." && pwd)
probe_resource=${SPARC_BOOTSTRAP_RESOURCE:-$probe_root}
probe_helper=${3:-"$probe_root/vm/cpu-sparc-trampoline.S"}
probe_dir=$(mktemp -d)
trap 'rm -rf "$probe_dir"' EXIT
for probe_bits in 32 64; do
  "$1" -i="$2" -resource-path="$probe_resource" -no-monitors \
    "$probe_root/misc/qemu/sparc-callstack-probe.factor" "$probe_bits" "$probe_dir/"
  python3 "$probe_root/misc/qemu/sparc-callstack-header.py" "$probe_dir"
  probe_flags=()
  probe_qemu=qemu-sparc64
  if [[ $probe_bits = 32 ]]; then
    probe_flags=(-m32)
    probe_qemu=qemu-sparc32plus
  fi
  cookie_flags=()
  cookie_objects=()
  prepare_flags=()
  if [[ ${SPARC_CALLSTACK_PREPARE:-0} == 1 ]]; then
    prepare_flags=(-DSPARC_EXPECT_PREPARE -Wl,--wrap=factor_sparc_prepare_callstack)
  fi
  if [[ -n ${SPARC_COOKIE_SOURCE:-} ]]; then
    sparc64-linux-gnu-g++ "${probe_flags[@]}" -c "$SPARC_COOKIE_SOURCE" -o "$probe_dir/cookie.o"
    cookie_flags=(-DSPARC_EXTERNAL_COOKIE)
    cookie_objects=("$probe_dir/cookie.o")
  fi
  sparc64-linux-gnu-gcc "${probe_flags[@]}" "${cookie_flags[@]}" "${prepare_flags[@]}" -static \
    -ffixed-g2 -ffixed-g3 -ffixed-g4 -ffixed-g5 -I"$probe_dir" \
    "$probe_root/misc/qemu/sparc-callstack-probe.c" \
    "$probe_root/misc/qemu/sparc-callstack-probe.S" "$probe_helper" "${cookie_objects[@]}" \
    -o "$probe_dir/callstack-probe"
  "$probe_qemu" "$probe_dir/callstack-probe"
done
