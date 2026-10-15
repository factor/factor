#!/bin/bash
# Run in an identity-mapped private user, mount, and PID namespace.
set -eu
state=$1 uid=$2 gid=$3 registration=$4
shift 4
child=
monitor=
cleanup() {
    if [ -n "$monitor" ]; then kill "$monitor" 2>/dev/null || true; fi
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
cat /proc/self/uid_map >"$state/uid-map"
cat /proc/self/gid_map >"$state/gid-map"
mount --make-rprivate /
mount -t proc proc /proc
mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc
# A new user namespace must have its own empty registry.
for entry in /proc/sys/fs/binfmt_misc/*; do
    case ${entry##*/} in register|status) ;; *) exit 1 ;; esac
done
cat "$registration" >/proc/sys/fs/binfmt_misc/register
cat /proc/sys/fs/binfmt_misc/factor-s390x-private >"$state/private-registration"
# sudo retains a root identity environment even after setpriv changes UID.
# Derive defaults from the actual target account; an explicit env command
# may still choose a per-run cache directory.
account=$(getent passwd "$uid")
IFS=: read -r target_name _ _ _ _ target_home _ <<< "$account"
case "$target_home" in /*) ;; *) exit 1 ;; esac
setsid setpriv --reuid="$uid" --regid="$gid" --clear-groups \
    --inh-caps=-all --ambient-caps=-all --bounding-set=-all \
    /usr/bin/env HOME="$target_home" USER="$target_name" LOGNAME="$target_name" \
    XDG_CACHE_HOME="$target_home/.cache" "$@" &
child=$!
expected=$(sed -n 's/^interpreter //p' "$state/private-registration")
for attempt in $(seq 1 100); do
    executable=$(readlink "/proc/$child/exe" 2>/dev/null || true)
    if [ "$executable" = "$expected" ]; then
        printf '%s\n' "$executable" >"$state/parent-executable"
        cat "/proc/$child/status" >"$state/parent-status"
        break
    fi
    sleep .01
done
(
    while kill -0 "$child" 2>/dev/null; do
        for proc in /proc/[0-9]*; do
            pid=${proc##*/}
            [ "$pid" != "$child" ] || continue
            executable=$(readlink "$proc/exe" 2>/dev/null || true)
            if [ "$executable" = "$expected" ]; then
                printf '%s\n' "$executable" >"$state/child-$pid-executable"
                cat "$proc/status" >"$state/child-$pid-status" 2>/dev/null || true
            fi
        done
        sleep .05
    done
) &
monitor=$!
set +e
wait "$child"
result=$?
echo "$result" >"$state/command.exitcode"
exit "$result"
