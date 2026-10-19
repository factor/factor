#!/usr/bin/env bash
set -euo pipefail
kernel=$(realpath "${1:?usage: kernel-probe.sh /path/to/HPPA32/vmlinuz}")
repo=$(cd -- "$(dirname -- "$0")/../../.." && pwd)
assets=${FACTOR_HPPA_PROBE_ASSETS:-$repo/work/qemu-matrix/new-linux/hppa/kernel-probe-$(date -u +%Y%m%dT%H%M%SZ)}
mkdir -p "$assets"
assets=$(realpath "$assets")
[[ ! -e "$assets/guest.pid" ]]
build=${FACTOR_HPPA_BUILD_DIR:-$assets/build}
cc=${CC:-hppa-linux-gnu-gcc}
cxx=${CXX:-hppa-linux-gnu-g++}
cd "$repo"
{
 git rev-parse HEAD
 "$cc" --version
 "$cxx" --version
 qemu-system-hppa --version
 sha256sum "$kernel"
} > "$assets/provenance.txt"
git diff --binary > "$assets/source.patch"
find vm misc/qemu/hppa -type f -print0 | sort -z | xargs -0 sha256sum > "$assets/source-sha256.txt"
CC="$cc" CXX="$cxx" AR="${AR:-hppa-linux-gnu-ar}" make -j2 \
 "$build/gc-tests" CONFIG=vm/Config.linux.hppa.32 BUILD_DIR="$build" > "$assets/build.log" 2>&1
initrd=$assets/initrd
mkdir -p "$initrd"/{dev,proc,sys,tmp}
"$cc" -static -O2 misc/qemu/hppa/abi-probe.c -latomic -o "$initrd/abi-probe"
"$cxx" -static -O2 misc/qemu/hppa/code-probe.cpp -o "$initrd/code-probe"
"$cc" -static -O2 misc/qemu/hppa/signal-probe.c misc/qemu/hppa/signal-probe.S -o "$initrd/signal-probe"
"$cc" -static -O2 misc/qemu/hppa/gate-probe.c misc/qemu/hppa/gate-probe.S vm/cpu-hppa-trampoline.S -o "$initrd/gate-probe"
"$cc" -static -O2 misc/qemu/hppa/atomic-signal-probe.c -o "$initrd/atomic-signal-probe"
"$cc" -static -O2 misc/qemu/hppa/kernel-probe-init.c -o "$initrd/init"
python3 - "$cxx" "$build" "$initrd/gc-tests" <<'PY'
import glob,subprocess,sys
objects=[p for p in glob.glob(sys.argv[2]+'/*.o') if not p.endswith(('/main-unix.o','/ffi_test.o'))]
subprocess.run([sys.argv[1],'-static','-O2','-std=c++17','vm/tests/gc.cpp',*objects,
 '-ldl','-lm','-lrt','-lpthread','-Wl,--export-dynamic','-o',sys.argv[3]],check=True)
PY
(cd "$initrd"; find . -print0 | cpio --null -o --format=newc 2> "$assets/cpio.log" | gzip -n > "$assets/initrd.cpio.gz")
sha256sum "$assets/initrd.cpio.gz" "$initrd"/*-probe "$initrd/gc-tests" >> "$assets/provenance.txt"
python3 - "$assets" "$kernel" <<'PY'
import pathlib,subprocess,sys
assets=pathlib.Path(sys.argv[1]);kernel=sys.argv[2]
args=['qemu-system-hppa','-machine','B160L','-m','512','-accel','tcg',
 '-nographic','-monitor','none','-serial',f'file:{assets}/console.log',
 '-kernel',kernel,'-initrd',str(assets/'initrd.cpio.gz'),
 '-append','console=ttyS0 rdinit=/init panic=0','-nic','none']
with open(assets/'qemu.log','ab') as log:
 proc=subprocess.Popen(args,stdin=subprocess.DEVNULL,stdout=log,stderr=log,start_new_session=True)
(assets/'guest.pid').write_text(str(proc.pid)+'\n')
(assets/'command.txt').write_text(repr(args)+'\n')
PY
printf 'Kernel probes started; inspect %s/console.log for HPPA_NATIVE_KERNEL_PROBES_FAILURES=0\n' "$assets"
python3 - "$assets" <<'PY'
import pathlib,re,sys,time
assets=pathlib.Path(sys.argv[1]);console=assets/'console.log'
for attempt in range(120):
 text=console.read_text(errors='replace') if console.exists() else ''
 match=re.search(r'HPPA_NATIVE_KERNEL_PROBES_FAILURES=(\d+)',text)
 if match:
  expected=['abi-probe','code-probe','signal-probe','gate-probe','atomic-signal-probe','gc-tests']
  passed=all(f'HPPA native kernel test=/{name} status=0' in text for name in expected)
  print(text[text.find('HPPA native kernel probe:'):])
  sys.exit(0 if match.group(1)=='0' and passed else 1)
 time.sleep(1)
print(f'Kernel probe completion pending; inspect {console}',file=sys.stderr)
sys.exit(124)
PY
