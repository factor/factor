// Copyright (C) 2022-2024 nomennescio
// See https://factorcode.org/license.txt for BSD license.

#include "master.hpp"

namespace lib { namespace zstd {
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
    handle = nullptr;
  }
} }
