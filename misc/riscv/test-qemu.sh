#!/usr/bin/env bash
set -euo pipefail
export PATH="$PATH:/usr/sbin:/sbin"

usage() {
    cat <<'EOF'
Usage: test-qemu.sh [options] 32|64 ROOTFS CHECKOUT [SEED_IMAGE]

Run on Linux with a prepared RISC-V root filesystem, a cross-built Factor
checkout, static qemu-riscv32 or qemu-riscv64, and passwordless sudo.
The root filesystem needs Xvfb and the vocabulary runtime dependencies.
Full test-all also needs target Git and a checkout with Git history.
RV32: misc/riscv32/build.sh supplies the root filesystem and cross compiler.
RV64: use a Debian riscv64 root filesystem and build.sh deps-apt-tests.

Options:
  --image FILE     Restore an existing bootstrap image instead of bootstrapping
  --gui-image FILE Clean bootstrap image for GUI and test children when restoring a loaded image
  --stage STAGE    all (default), bootstrap, prefixes, essentials, load-all, test-all, probe
  --output DIR     Results directory inside CHECKOUT (default: timestamped build/)
  --vm FILE        Executable in CHECKOUT (default: factor)
  --qemu FILE      Static QEMU interpreter (default: system qemu-user-static)
  -h, --help       Show this help

The default seed is CHECKOUT/boot.unix-riscv.WIDTH.image. Generate it with
bootstrap.image on a working host Factor before cross-building the VM.
All runs use a private binfmt/mount/PID namespace; global handlers are untouched.
PGHOST, PGPORT, PGUSER, PGPASSWORD, REDIS_HOST and REDIS_PORT configure test
services. PostgreSQL needs a login role with CREATEDB; Redis tests use database 0.
Use dedicated test services. The runner preserves normal vocabulary test tags.
EOF
}

# Keep EXIT cleanup inside the function's scope, including failed stages.
namespace_worker() (
    local parent_mount=$1 bits=$2 root=$3 checkout=$4
    local results=$5 vm=$6 stage=$7 input=$8 emulator=$9
    [[ $(stat -Lc '%i' /proc/self/ns/mnt) != "$parent_mount" ]] || {
        echo 'The namespace worker must run through unshare.' >&2; exit 1;
    }
    mount --bind "$root" "$root"
    mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc
    python3 - "$bits" "$emulator" <<'PY'
from pathlib import Path
import sys
bits = sys.argv[1]
magic = bytearray(20)
magic[:7] = b'\x7fELF' + bytes([1 if bits == '32' else 2, 1, 1])
magic[16] = 2
magic[18] = 0xf3
mask = bytearray(20)
mask[:7] = b'\xff' * 7
mask[16:20] = b'\xfe\xff\xff\xff'
escape = lambda value: ''.join('\\x%02x' % byte for byte in value)
rule = f':factor-rv{bits}:M::{escape(magic)}:{escape(mask)}:{sys.argv[2]}:F\n'
Path('/proc/sys/fs/binfmt_misc/register').write_text(rule)
PY
    mkdir -p "$root/proc" "$root/dev" "$root/root/factor"
    mount -t proc proc "$root/proc"
    mount --rbind /dev "$root/dev"
    mount --make-rslave "$root/dev"
    mount --bind "$checkout" "$root/root/factor"
    case "$stage" in
        all|test-all)
            chroot "$root" /bin/sh -c 'command -v git >/dev/null' || {
                echo 'Install Git in ROOTFS for standard test-all.' >&2; exit 1;
            }
            # The private guest runs as root over the caller-owned checkout.
            export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.directory
            export GIT_CONFIG_VALUE_0=/root/factor
            ;;
    esac
    export QEMU_LD_PREFIX=/ FACTOR_RISCV_BITS="$bits"
    local guest_results="/root/factor/${results#"$checkout/"}"
    local image="$guest_results/$input"
    local default_image placeholder= default_mounted=
    default_image=$(realpath -m -- "$root/root/factor/$vm.image")
    [[ $default_image == "$root/root/factor/"* ]] || {
        echo 'The default VM image must resolve inside CHECKOUT.' >&2; exit 1;
    }
    if [[ ! -e $default_image ]]; then
        touch "$default_image"
        placeholder=$default_image
    fi
    cleanup_default_image() {
        if [[ -n $default_mounted ]]; then umount "$default_image"; fi
        if [[ -n $placeholder ]]; then rm -f -- "$placeholder"; fi
    }
    trap cleanup_default_image EXIT
    bind_default_image() {
        if [[ -n $default_mounted ]]; then umount "$default_image"; fi
        default_mounted=
        mount --bind "$root$image" "$default_image"
        default_mounted=1
    }
    run_factor() {
        local label=$1
        shift
        local result=0
        echo "Running $label: $results/$label.log"
        chroot "$root" /bin/sh -c \
            '
            set -eu
            cd /root/factor
            if command -v xvfb-run >/dev/null; then
                exec xvfb-run -a "$@"
            fi
            display_file=$(mktemp)
            Xvfb -displayfd 3 -screen 0 1280x1024x24 -nolisten tcp -ac \
                3>"$display_file" >"$display_file.log" 2>&1 &
            xvfb_pid=$!
            cleanup() {
                kill "$xvfb_pid" 2>/dev/null || true
                wait "$xvfb_pid" 2>/dev/null || true
                rm -f "$display_file" "$display_file.log"
            }
            trap cleanup EXIT
            trap "exit 130" INT
            trap "exit 143" HUP TERM
            attempts=0
            while [ ! -s "$display_file" ]; do
                if ! kill -0 "$xvfb_pid" 2>/dev/null || [ "$attempts" -ge 60 ]; then
                    cat "$display_file.log" >&2
                    echo "Xvfb failed to start." >&2
                    exit 1
                fi
                attempts=$((attempts + 1))
                sleep 1
            done
            export DISPLAY=":$(cat "$display_file")"
            result=0
            "$@" || result=$?
            exit "$result"
            ' factor \
            "./$vm" -resource-path=/root/factor -no-user-init "$@" \
            > "$results/$label.log" 2>&1 || result=$?
        printf '%s\n' "$result" > "$results/$label.exit"
        if (( result != 0 )); then
            tail -n 60 "$results/$label.log" >&2
            return "$result"
        fi
        echo "$label passed: $results/$label.log"
    }
    run_validation() {
        local part=$1 output=$2
        bind_default_image
        run_factor "$part" "-i=/root/factor/$vm.image" \
            /root/factor/misc/riscv/test-qemu.factor "$part" "$guest_results/$output"
    }
    if [[ $input == seed.image ]]; then
        run_factor bootstrap "-i=$image" "-output-image=$guest_results/bootstrap.image"
        image="$guest_results/bootstrap.image"
    fi
    export FACTOR_GUI_TEST_IMAGE="$image"
    if [[ -f $results/gui.image ]]; then
        export FACTOR_GUI_TEST_IMAGE="$guest_results/gui.image"
    fi
    export FACTOR_TEST_CHILD_IMAGE="$FACTOR_GUI_TEST_IMAGE"
    case "$stage" in
        bootstrap) run_validation probe bootstrap-verified.image ;;
        prefixes|essentials|probe) run_validation "$stage" "$stage.image" ;;
        load-all) run_validation load-all loaded.image ;;
        test-all) run_validation test-all tested.image ;;
        all)
            run_validation probe bootstrap-verified.image
            image="$guest_results/bootstrap-verified.image"
            if [[ ! -f $results/gui.image ]]; then
                export FACTOR_GUI_TEST_IMAGE="$image"
                export FACTOR_TEST_CHILD_IMAGE="$image"
            fi
            run_validation prefixes prefixes.image
            run_validation load-all loaded.image
            image="$guest_results/loaded.image"
            run_validation test-all tested.image
            ;;
    esac
    cleanup_default_image
    trap - EXIT
)

if [[ ${1:-} == --namespace-worker ]]; then
    shift
    namespace_worker "$@"
    exit
fi

stage=all
resume_image=
gui_image=
output=
vm=factor
emulator=
while [[ $# -gt 0 ]]; do
    case $1 in
        --image|--gui-image|--stage|--output|--vm|--qemu)
            [[ $# -ge 2 ]] || { usage >&2; exit 2; }
            case $1 in
                --image) resume_image=$2 ;; --stage) stage=$2 ;;
                --gui-image) gui_image=$2 ;;
                --output) output=$2 ;; --vm) vm=$2 ;;
                --qemu) emulator=$2 ;;
            esac
            shift 2 ;;
        -h|--help) usage; exit 0 ;;
        --*) usage >&2; exit 2 ;;
        *) break ;;
    esac
done
[[ $# -ge 3 && $# -le 4 ]] || { usage >&2; exit 2; }
bits=$1
[[ $bits == 32 || $bits == 64 ]] || { usage >&2; exit 2; }
case $stage in all|bootstrap|prefixes|essentials|load-all|test-all|probe) ;; *) usage >&2; exit 2 ;; esac
[[ $(uname -s) == Linux ]] || { echo 'Run this script on Linux.' >&2; exit 1; }
[[ $vm != */* && $vm != .* ]] || { echo '--vm must name an executable in CHECKOUT.' >&2; exit 2; }
for command in python3 unshare mount umount chroot sudo realpath file; do
    command -v "$command" >/dev/null || { echo "Missing command: $command" >&2; exit 1; }
done
root=$(realpath -e -- "$2")
checkout=$(realpath -e -- "$3")
[[ $root != / && $root != "$checkout" && $root != "$checkout/"* && $checkout != "$root/"* ]] || {
    echo 'ROOTFS and CHECKOUT must be separate, non-nested directories.' >&2; exit 2;
}
case "$stage" in
    all|test-all)
        command -v git >/dev/null || { echo 'Install Git on the builder.' >&2; exit 1; }
        git -C "$checkout" rev-parse --verify HEAD >/dev/null 2>&1 || {
            echo 'CHECKOUT needs Git history for standard test-all; use a Git clone.' >&2; exit 1;
        }
        ;;
esac
script=$(realpath -e -- "${BASH_SOURCE[0]}")
[[ -f $checkout/misc/riscv/test-qemu.factor ]] || { echo 'CHECKOUT needs the current validation helper.' >&2; exit 1; }
[[ -x $checkout/$vm ]] || { echo "Missing target executable: $checkout/$vm" >&2; exit 1; }
if [[ -n $emulator ]]; then
    emulator=$(realpath -e -- "$emulator")
    [[ -x $emulator ]] || { echo '--qemu must be executable.' >&2; exit 2; }
    case $(LC_ALL=C file -L "$emulator") in
        *'statically linked'*|*'static-pie linked'*) ;;
        *) echo '--qemu must be statically linked.' >&2; exit 2 ;;
    esac
else
    for candidate in "/usr/bin/qemu-riscv$bits-static" "/usr/bin/qemu-riscv$bits"; do
        [[ -x $candidate ]] || continue
        case $(LC_ALL=C file -L "$candidate") in
            *'statically linked'*|*'static-pie linked'*) emulator=$candidate; break ;;
        esac
    done
fi
[[ -n $emulator ]] || { echo 'Install a static RISC-V interpreter from qemu-user-static.' >&2; exit 1; }
python3 - "$checkout/$vm" "$bits" <<'PY'
import struct, sys
with open(sys.argv[1], 'rb') as executable:
    header = executable.read(64)
bits = int(sys.argv[2])
if len(header) < 52 or header[:7] != b'\x7fELF' + bytes([1 if bits == 32 else 2, 1, 1]):
    raise SystemExit('Factor must be a little-endian target ELF executable')
if struct.unpack_from('<H', header, 18)[0] != 243:
    raise SystemExit('Factor must be built for RISC-V')
flags = struct.unpack_from('<I', header, 36 if bits == 32 else 48)[0]
if flags & 6 != 4:
    raise SystemExit('Factor must use the ILP32D/LP64D ABI')
PY
output=${output:-"$checkout/build/riscv-qemu/$bits/$(date -u +%Y%m%dT%H%M%SZ)"}
mkdir -p -- "$output"
output=$(realpath -e -- "$output")
[[ $output == "$checkout/"* ]] || { echo '--output must be inside CHECKOUT.' >&2; exit 2; }
[[ ! -e $output/start.image && ! -e $output/seed.image && ! -e $output/gui.image && ! -e $output/result.exit ]] || {
    echo 'Use a new results directory to preserve earlier runs.' >&2; exit 2;
}
if [[ -n $resume_image ]]; then
    input=$(realpath -e -- "$resume_image")
    cp -- "$input" "$output/start.image"
    input=start.image
else
    seed=$(realpath -e -- "${4:-$checkout/boot.unix-riscv.$bits.image}")
    cp -- "$seed" "$output/seed.image"
    input=seed.image
fi
if [[ -n $gui_image ]]; then
    gui_image=$(realpath -e -- "$gui_image")
    cp -- "$gui_image" "$output/gui.image"
fi
parent_mount=$(stat -Lc '%i' /proc/self/ns/mnt)
result=0
sudo -n --preserve-env=PGHOST,PGPORT,PGUSER,PGPASSWORD,REDIS_HOST,REDIS_PORT \
    unshare --user --map-users=0:0:65536 --map-groups=0:0:65536 \
    --setgroups=allow --mount --propagation private --pid --fork --mount-proc \
    "$script" --namespace-worker "$parent_mount" "$bits" "$root" "$checkout" \
    "$output" "$vm" "$stage" "$input" "$emulator" || result=$?
printf '%s\n' "$result" > "$output/result.exit"
echo "Results: $output"
exit "$result"
