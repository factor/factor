#!/usr/bin/env bash
# Fast CLI checks. Does not fetch sources, run compilers, or require VS.
set -Eeuo pipefail
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
driver="$script_dir/build-current.sh"
bash -n "$driver"
bash "$driver" --help >/dev/null
reject() {
    local code=0
    bash "$driver" "$@" >/dev/null 2>&1 || code=$?
    [[ $code == 2 ]] || { echo "Expected usage exit 2 for: $* (got $code)" >&2; exit 1; }
}
reject --unknown
reject --arch invalid
reject --jobs 0
reject --jobs -1
reject --projects unknown
echo 'PASS: shell syntax, help, and invalid-argument checks'
