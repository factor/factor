#!/bin/sh
set -eu
cd "${1:-.}"
uname -a
sysctl hw.machine hw.model
sysctl hw.ncpu hw.byteorder || true
command -v c++
c++ --version
c++ -std=c++17 -fPIC -shared -DABI_LIBRARY openbsd-macppc-abi.cpp -o libabi-probe.so
c++ -std=c++17 -O2 openbsd-macppc-abi.cpp -o abi-probe
file abi-probe libabi-probe.so
ldd abi-probe
./abi-probe
sha256 abi-probe libabi-probe.so openbsd-macppc-abi.cpp
cc -std=c11 -O0 openbsd-macppc-layout.c -o abi-layout
cc -std=c11 -O0 -S -emit-llvm openbsd-macppc-layout.c -o abi-layout.ll
./abi-layout
grep -E '^define.*@(ret[3589]|arg[3589]|complex_)' abi-layout.ll
sha256 abi-layout openbsd-macppc-layout.c abi-layout.ll
cc -std=c11 openbsd-macppc-time.c -o abi-time
./abi-time
sha256 abi-time openbsd-macppc-time.c

cc -std=c11 -O0 openbsd-macppc-fpsig.c -o abi-fpsig
./abi-fpsig
sha256 abi-fpsig openbsd-macppc-fpsig.c
echo FOUNDATION_ALL_EXIT0
