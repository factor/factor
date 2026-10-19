#!/bin/bash
# Native OS/compiler checks; no claim of Factor bootstrap or tests.
set -euo pipefail
if [ "$#" -ne 3 ]; then echo "usage: $0 SSH_PORT PRIVATE_KEY OUTPUT_DIR" >&2; exit 2; fi
port=$1
key=$2
out=$3
mkdir -p "$out"
base=$(cd "$(dirname "$0")" && pwd)
opts=(-i "$key" -p "$port" -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=20)
ssh "${opts[@]}" root@127.0.0.1 'uname -a; uname -m; cc --version | head -3' 2>&1 | tee "$out/native-platform.log"
ssh "${opts[@]}" root@127.0.0.1 'cat > /tmp/bsd-native-foundation.c' < "$base/bsd-native-foundation.c"
ssh "${opts[@]}" root@127.0.0.1 'cc -O2 /tmp/bsd-native-foundation.c -lm -o /tmp/bsd-native-foundation && /tmp/bsd-native-foundation' 2>&1 | tee "$out/native-foundation.log"
grep -q '^NATIVE_FOUNDATION_PASS ' "$out/native-foundation.log"
