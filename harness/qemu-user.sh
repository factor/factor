#!/bin/sh
# Run a Linux user-emulation command with a relocated library closure.
set -eu

qemu=$1
cpu=$2
runtime_root=$3
shift 3

export QEMU_LD_PREFIX="$runtime_root"
export FONTCONFIG_PATH="$runtime_root/etc/fonts"
export FONTCONFIG_FILE=fonts.conf
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$runtime_root/var/cache}"
export OPENSSL_CONF="$runtime_root/etc/ssl/openssl.cnf"

# Pass guest library paths through QEMU, keeping them out of the host loader.
guest_library_path="$runtime_root/lib:$runtime_root/usr/lib"
if [ -n "${LD_LIBRARY_PATH:-}" ]; then
    guest_library_path="$LD_LIBRARY_PATH:$guest_library_path"
fi
unset LD_LIBRARY_PATH
exec "$qemu" -cpu "$cpu" -L "$runtime_root" \
    -E LD_LIBRARY_PATH="$guest_library_path" "$@"
