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
BEGIN_PRAGMA (diagnostic ignored "-Wunused-function") // ignore unused function warnings
#include "zstd.c"
END_PRAGMA
  } }
  size_t ZSTD_decompress (void* dst, size_t dstCapacity, const void* src, size_t compressedSize) { return c::ZSTD_decompress (dst, dstCapacity, src, compressedSize); }
  unsigned ZSTD_isError (size_t code) { return c::ZSTD_isError (code); }
  const char* ZSTD_getErrorName (size_t code) { return c::ZSTD_getErrorName (code); }

  void zstd_lib::open() {
    handle = factor::native_dlopen(ZSTD_LIB);
    if (!handle)
      factor::fatal_error(
          "Unable to find zstd library to open compressed image", 0);
    *(void**)(&decompress) = factor::native_dlsym(handle, "ZSTD_decompress");
    *(void**)(&is_error) = factor::native_dlsym(handle, "ZSTD_isError");
    *(void**)(&get_error_name) = factor::native_dlsym(handle, "ZSTD_getErrorName");
    if (!decompress || !is_error || !get_error_name)
      factor::fatal_error(
          "Unable to find zstd functions to open compressed image", 0);
  }

  void zstd_lib::close() {
    factor::native_dlclose(handle);
    handle = NULL;
  }
} }
