// Copyright (C) 2022-2024 nomennescio
// See https://factorcode.org/license.txt for BSD license.

namespace lib { namespace zstd {
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
