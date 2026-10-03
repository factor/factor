#!/bin/sh
set -eu

# Buildroot post-build hook. Also usable as `provision.sh /` inside the guest.
# Preserve the service database while making HTTP's canonical name consistent
# with the network-protocol compiler fixture; retain www as its alias.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 TARGET_ROOT_DIRECTORY" >&2
    exit 1
fi
services="$1/etc/services"
temporary=$(mktemp "$services.XXXXXX")
trap 'rm -f "$temporary"' 0
sed -e 's/^www\([[:space:]][[:space:]]*80\/tcp[[:space:]][[:space:]]*\)http$/http\1www/' \
    -e 's/^www\([[:space:]][[:space:]]*80\/tcp[[:space:]][[:space:]]*\)http\([[:space:]]\)/http\1www\2/' \
    "$services" > "$temporary"
awk '
    $1 == "http" && $2 == "80/tcp" {
        for (i = 3; i <= NF && $i !~ /^#/; i++)
            if ($i == "www") found = 1
    }
    END { exit !found }
' "$temporary"
chmod 644 "$temporary"
mv "$temporary" "$services"
