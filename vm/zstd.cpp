// Copyright (C) 2022-2024 nomennescio
// See https://factorcode.org/license.txt for BSD license.

#if defined(__clang__)
// clang++ issue: https://github.com/nlohmann/json/pull/1551
#pragma clang diagnostic ignored "-Wc++1z-extensions"
#endif

#include "master.hpp"

// zstd.c is generated from github.com/facebook/zstd.git using
// $ cd zstd/build/single_file_libs
// $ python combine.py -r ../../lib -o zstd.c zstd-in.c
// $ cp zstd.c ../../../factor/vm/zstd.c

namespace lib { namespace zstd {
  namespace c { extern "C" {
// update the following line if zstd.c is updated
// origin : git SHA1: 794ea1b0 tag: v1.5.6
#include "zstd.c"
  } }
  size_t ZSTD_decompress (void* dst, size_t dstCapacity, const void* src, size_t compressedSize) { return c::ZSTD_decompress (dst, dstCapacity, src, compressedSize); }
  unsigned ZSTD_isError (size_t code) { return c::ZSTD_isError (code); }
  const char* ZSTD_getErrorName (size_t code) { return c::ZSTD_getErrorName (code); }
} }
