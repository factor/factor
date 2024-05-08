// Copyright (C) 2022-2024 nomennescio
// See https://factorcode.org/license.txt for BSD license.

// clang++ issue: https://github.com/nlohmann/json/pull/1551
#pragma clang diagnostic ignored "-Wc++1z-extensions"

#include "master.hpp"

namespace lib { namespace zstd { extern "C" {
#include "zstd.c"
} } }
