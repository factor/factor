! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: continuations cpu.arm.64.features kernel literals locals
math sequences system vocabs vocabs.loader ;
IN: cpu.arm.64.features.windows

! IsProcessorFeaturePresent IDs, not HWCAP bits. See the Microsoft API
! reference for processthreadsapi.h. The NEON IDs below are distinct from
! PF_ARM_SVE_BF16_INSTRUCTIONS_AVAILABLE (52) and SVE_I8MM (57).
CONSTANT: PF_ARM_V82_DP_INSTRUCTIONS_AVAILABLE 43
CONSTANT: PF_ARM_V82_I8MM_INSTRUCTIONS_AVAILABLE 66
CONSTANT: PF_ARM_V82_FP16_INSTRUCTIONS_AVAILABLE 67
CONSTANT: PF_ARM_V86_BF16_INSTRUCTIONS_AVAILABLE 68

! Keeping the query injectable permits testing every HAL response without
! executing optional opcodes or loading Kernel32 on non-Windows hosts.
:: windows-query>arm64-features ( query: ( id -- present ) -- features )
    {
        { "dotprod" $ PF_ARM_V82_DP_INSTRUCTIONS_AVAILABLE }
        { "fp16" $ PF_ARM_V82_FP16_INSTRUCTIONS_AVAILABLE }
        { "bf16" $ PF_ARM_V86_BF16_INSTRUCTIONS_AVAILABLE }
        { "i8mm" $ PF_ARM_V82_I8MM_INSTRUCTIONS_AVAILABLE }
    } [ second [ query call zero? not ] [ 2drop f ] recover ] filter
    [ first ] map ; inline

HOOK: windows-processor-feature os ( id -- present )
M: object windows-processor-feature drop 0 ;

M: windows probe-arm64-features
    [ windows-processor-feature ] windows-query>arm64-features ;

os windows? [ "cpu.arm.64.features.windows.kernel32" require ] when
