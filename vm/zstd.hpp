// Copyright (C) 2022-2024 nomennescio
// See https://factorcode.org/license.txt for BSD license.

// zstd.h is copied from github.com/facebook/zstd.git using
// $ cp zstd/lib/zstd.h factor/vm/zstd.h

// because we import external code here, which we don't want to alter, we need to handle integration here

// ignore unused function warnings
#if defined(__clang__)
#pragma clang diagnostic ignored "-Wunused-function"
#elif defined (__GNUC__)
#pragma GCC diagnostic ignored "-Wunused-function"
#endif

namespace lib { namespace zstd {
  namespace c { extern "C" {
#define ZSTDLIB_VISIBILITY static
#define ZSTD_STATIC_LINKING_ONLY // enable advanced experimental functions
// update the following line if zstd.h is updated
// origin : git SHA1: 794ea1b0 tag: v1.5.6
#include "zstd.h"
  } }
  extern size_t ZSTD_decompress (void* dst, size_t dstCapacity, const void* src, size_t compressedSize);
  extern unsigned ZSTD_isError (size_t code);
  extern const char* ZSTD_getErrorName (size_t code);
} }
