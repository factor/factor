#!/bin/bash
set -eu
state=$1 uid=$2 gid=$3 groups=$4
shift 4
child=
cleanup() {
    if [ -n "$child" ]; then
        kill -TERM -- "-$child" 2>/dev/null || true
        sleep .2
        kill -KILL -- "-$child" 2>/dev/null || true
        wait "$child" 2>/dev/null || true
    fi
}
trap cleanup EXIT
trap 'exit 143' TERM HUP
trap 'exit 130' INT
read -r host_pid remainder < /proc/self/stat
mount --make-rprivate /
mount -t proc proc /proc
ip link set lo up
mount --bind "$state/tmp" /tmp
mount --bind "$state/resolv.conf" /etc/resolv.conf
if [ -f "$state/resolver-target" ]; then
    IFS= read -r resolver_target < "$state/resolver-target"
    mount --bind "$state/resolv.conf" "$resolver_target"
fi
echo "$host_pid" > "$state/ns.pid"
while [ ! -f "$state/go" ]; do sleep .1; done
group_option=(--clear-groups)
if [ -n "$groups" ]; then group_option=("--groups=$groups"); fi
setsid setpriv --reuid="$uid" --regid="$gid" "${group_option[@]}" --inh-caps=-all --ambient-caps=-all --bounding-set=-all "$@" &
child=$!
echo "$child" > "$state/command-nspid"
set +e
wait "$child"
result=$?
exit "$result"
