/* Copyright (C) 2026 Factor contributors.
 * See https://factorcode.org/license.txt for BSD license. */
#ifndef FACTOR_FFI_TEST_FEATURES_H
#define FACTOR_FFI_TEST_FEATURES_H

/* Clang 18 accepts __bf16 arithmetic on AArch64 but can crash selecting
 * f64 -> bf16 FP_ROUND (Ubuntu Clang 18.1.3, baseline Linux ARM64).
 * Keep these optional native ABI oracles and their capability queries in
 * sync. This does not disable Factor's own half/bfloat implementation. */
#if (defined(__aarch64__) || defined(_M_ARM64)) && \
    defined(__clang__) && __clang_major__ >= 19
#define FACTOR_TEST_SMALL_FLOATS 1
#else
#define FACTOR_TEST_SMALL_FLOATS 0
#endif

#endif
