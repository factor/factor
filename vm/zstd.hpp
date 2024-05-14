// Copyright (C) 2022-2024 nomennescio
// See https://factorcode.org/license.txt for BSD license.

namespace lib { namespace zstd { extern "C" {
#define ZSTD_STATIC_LINKING_ONLY // enable advanced experimental functions
#include "zstd.h"
} } }
