// Copyright (C) 2022-2024 nomennescio
// See https://factorcode.org/license.txt for BSD license.

// zstd.h is copied from github.com/facebook/zstd.git using
// $ cp zstd/lib/zstd.h factor/vm/zstd.h

// because we import external code here, which we don't want to alter, we need to handle integration here

#if defined (__clang__)||defined (__GNUC__)

#if defined(__clang__)
#define PRAGMA(pragma) \
    _Pragma(PRAGMA_STR(clang pragma))
#elif defined (__GNUC__)
#define PRAGMA(pragma) \
    _Pragma(PRAGMA_STR(GCC pragma))
#endif

#define PRAGMA_STR(x) #x
#define BEGIN_PRAGMA(pragma) \
    PRAGMA(diagnostic push) \
    PRAGMA(pragma)
#define END_PRAGMA \
    PRAGMA(diagnostic pop)

#else

#define BEGIN_PRAGMA(pragma)
#define END_PRAGMA

#endif

namespace lib { namespace zstd {
  namespace c { extern "C" {
#define ZSTDLIB_VISIBILITY static
#define ZSTD_STATIC_LINKING_ONLY // enable advanced experimental functions
// update the following line if zstd.h is updated
// origin : git SHA1: 794ea1b0 tag: v1.5.6
BEGIN_PRAGMA (diagnostic ignored "-Wunused-function") // ignore unused function warnings
#include "zstd.h"
END_PRAGMA
  } }
  extern size_t ZSTD_decompress (void* dst, size_t dstCapacity, const void* src, size_t compressedSize);
  extern unsigned ZSTD_isError (size_t code);
  extern const char* ZSTD_getErrorName (size_t code);

  struct zstd_lib {
    void* handle;

    size_t (*decompress)(void* dst, size_t dst_capacity, const void* src,
                         size_t compressed_size);
    unsigned (*is_error)(size_t code);
    const char* (*get_error_name)(size_t code);

    void open();
    void close();
  };
} }
