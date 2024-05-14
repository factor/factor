// Copyright (C) 2022-2024 nomennescio
// See https://factorcode.org/license.txt for BSD license.

// zstd.h is copied from github.com/facebook/zstd.git using
// $ cp zstd/lib/zstd.h factor/vm/zstd.h

namespace lib { namespace zstd { extern "C" {
#define ZSTD_STATIC_LINKING_ONLY // enable advanced experimental functions
// update the following line if zstd.h is updated
// origin : git SHA1: 794ea1b0 tag: v1.5.6
#include "zstd.h"
} } }
