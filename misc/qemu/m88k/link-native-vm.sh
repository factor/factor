#!/bin/sh
# Run inside the transferred vm-native directory on OpenBSD/luna88k.
set -eu
# The native gcc driver supplies crt/libgcc SjLj, never old libstdc++.
gcc -O2 -pthread -Wl,--export-dynamic -Wl,-z,wxneeded \
    objects/*.o cpu-m88k-trampoline.S locked-atomics.c \
    libcxx-vm.a libc++abi.a libcxx-vm.a -lm -o factor-m88k
sha256 factor-m88k
