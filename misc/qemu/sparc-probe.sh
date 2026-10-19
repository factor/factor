#!/usr/bin/env bash
# Usage: sparc-probe.sh KIND HOST_FACTOR HOST_IMAGE [NATIVE_HELPER_SOURCE]
# Execute emitted Factor code and native relocation controls in 32/64-bit QEMU.
set -euo pipefail
if [[ $# -lt 3 || $# -gt 4 ]]; then
  echo "Usage: $0 {callback,callstack,context,delete,pic,reset,start,unwind} HOST_FACTOR HOST_IMAGE [NATIVE_HELPER_SOURCE]" >&2
  exit 2
fi
probe_kind=$1
shift
case "$probe_kind" in
  callback|callstack|context|delete|pic|reset|start|unwind) ;;
  *) echo "Unknown SPARC probe: $probe_kind" >&2; exit 2 ;;
esac
probe_root=$(cd "$(dirname "$0")/../.." && pwd)
probe_resource=$probe_root
if [[ $probe_kind = callstack ]]; then
  probe_resource=${SPARC_BOOTSTRAP_RESOURCE:-$probe_root}
fi
probe_helper=${3:-"$probe_root/vm/cpu-sparc-trampoline.S"}
probe_assembly=$probe_kind
if [[ $probe_kind = delete ]]; then
  probe_assembly=context
fi
probe_dir=$(mktemp -d)
trap 'rm -rf "$probe_dir"' EXIT
for probe_bits in 32 64; do
  "$1" -i="$2" -resource-path="$probe_resource" -no-monitors \
    "$probe_root/misc/qemu/sparc-$probe_kind-probe.factor" "$probe_bits" "$probe_dir/"
  python3 "$probe_root/misc/qemu/sparc-probe-header.py" "$probe_kind" "$probe_dir"
  probe_flags=()
  probe_qemu=qemu-sparc64
  if [[ $probe_bits = 32 ]]; then
    probe_flags=(-m32)
    probe_qemu=qemu-sparc32plus
  fi
  cookie_flags=()
  cookie_objects=()
  prepare_flags=()
  if [[ $probe_kind = callstack ]]; then
    if [[ ${SPARC_CALLSTACK_PREPARE:-0} == 1 ]]; then
      prepare_flags=(-DSPARC_EXPECT_PREPARE -Wl,--wrap=factor_sparc_prepare_callstack)
    fi
    if [[ -n ${SPARC_COOKIE_SOURCE:-} ]]; then
      sparc64-linux-gnu-g++ "${probe_flags[@]}" -c "$SPARC_COOKIE_SOURCE" -o "$probe_dir/cookie.o"
      cookie_flags=(-DSPARC_EXTERNAL_COOKIE)
      cookie_objects=("$probe_dir/cookie.o")
    fi
  fi
  helper_objects=()
  if [[ $probe_kind != pic ]]; then
    helper_objects=("$probe_helper")
  fi
  if [[ $probe_kind = callback ]]; then
    helper_objects+=("$probe_root/vm/sparc-stackghost.cpp" -lm)
  fi
  sparc64-linux-gnu-gcc "${probe_flags[@]}" "${cookie_flags[@]}" "${prepare_flags[@]}" -static \
    -ffixed-g2 -ffixed-g3 -ffixed-g4 -ffixed-g5 -I"$probe_dir" \
    "$probe_root/misc/qemu/sparc-$probe_kind-probe.c" \
    "$probe_root/misc/qemu/sparc-$probe_assembly-probe.S" \
    "${helper_objects[@]}" "${cookie_objects[@]}" -o "$probe_dir/$probe_kind-probe"
  "$probe_qemu" "$probe_dir/$probe_kind-probe"
done
