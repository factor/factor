#!/bin/sh
# Maintainer-provided OpenBSD 7.7 guest; current supported release is 7.9.
set -eu
assets=${M88K_ASSETS:-"$PWD/work/qemu-matrix/m88k"}
mkdir -p "$assets"
fetch() { test -f "$assets/$1" || curl -fL "https://www.nk-home.net/~aoyama/liveimage/$2" -o "$assets/$1"; }
fetch liveimage.img.gz liveimage-luna88k-raw-20250518.img.gz
fetch boot boot
(cd "$assets" && printf '%s\n' \
 'b63061e4eda1c9f85a5ebd57edeba643d538d00feff51805ba03e2d78f70bc8a  liveimage.img.gz' \
 '69e5df2c13c6736c2df87e845c9ae6d8fd9f2a3dbf38871732af15333ce70ae1  boot' | sha256sum -c -)
test -f "$assets/liveimage.img" || gzip -dk "$assets/liveimage.img.gz"
exec gxemul -e luna-88k -d "$assets/liveimage.img" "$assets/boot"
