! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: continuations cpu.arm.64.features kernel math sequences system unix.sysctl ;
IN: cpu.arm.64.features.macos

: arm64-sysctl? ( name -- ? )
    [ sysctl-name-query-uint zero? not ] [ 2drop f ] recover ;

M: macos probe-arm64-features
    {
        { "dotprod" "hw.optional.arm.FEAT_DotProd" }
        { "fp16" "hw.optional.arm.FEAT_FP16" }
        { "bf16" "hw.optional.arm.FEAT_BF16" }
        { "i8mm" "hw.optional.arm.FEAT_I8MM" }
    } [ second arm64-sysctl? ] filter [ first ] map ;
