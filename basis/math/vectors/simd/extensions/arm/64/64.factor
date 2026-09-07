! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types combinators cpu.arm.64.assembler
cpu.arm.64.assembler.registers cpu.arm.64.features kernel
math.vectors.simd math.vectors.simd.extensions sequences system words ;
IN: math.vectors.simd.extensions.arm.64

<PRIVATE
! These words are never inlined into portable callers. Optional instructions
! remain in separate kernels, reached only after a runtime capability check.
: sdot4 ( a b c -- d )
    int-4 { char-16 char-16 int-4 } cdecl [
        V2 V0 V1 SDOT
        V0 V2 16B MOVv
    ] alien-assembly ;
\ sdot4 { "dotprod" } "required-arm64-features" set-word-prop

: udot4 ( a b c -- d )
    uint-4 { uchar-16 uchar-16 uint-4 } cdecl [
        V2 V0 V1 UDOT
        V0 V2 16B MOVv
    ] alien-assembly ;
\ udot4 { "dotprod" } "required-arm64-features" set-word-prop

: usdot4 ( a b c -- d )
    int-4 { uchar-16 char-16 int-4 } cdecl [
        V2 V0 V1 USDOT
        V0 V2 16B MOVv
    ] alien-assembly ;
\ usdot4 { "i8mm" } "required-arm64-features" set-word-prop

: smatmul ( a b c -- d )
    int-4 { char-16 char-16 int-4 } cdecl [
        V2 V0 V1 SMMLA
        V0 V2 16B MOVv
    ] alien-assembly ;
\ smatmul { "i8mm" } "required-arm64-features" set-word-prop

: umatmul ( a b c -- d )
    uint-4 { uchar-16 uchar-16 uint-4 } cdecl [
        V2 V0 V1 UMMLA
        V0 V2 16B MOVv
    ] alien-assembly ;
\ umatmul { "i8mm" } "required-arm64-features" set-word-prop

: usmatmul ( a b c -- d )
    int-4 { uchar-16 char-16 int-4 } cdecl [
        V2 V0 V1 USMMLA
        V0 V2 16B MOVv
    ] alien-assembly ;
\ usmatmul { "i8mm" } "required-arm64-features" set-word-prop

: bdot2 ( a b c -- d )
    float-4 { bfloat-8 bfloat-8 float-4 } cdecl [
        X9 FPCR MRS
        X10 0x200 1 MOVZ
        FPCR X10 MSR
        V2 V0 V1 BFDOT
        V0 V2 16B MOVv
        FPCR X9 MSR
    ] alien-assembly ;
\ bdot2 { "bf16" } "required-arm64-features" set-word-prop

: bmatmul ( a b c -- d )
    float-4 { bfloat-8 bfloat-8 float-4 } cdecl [
        X9 FPCR MRS
        X10 0x200 1 MOVZ
        FPCR X10 MSR
        V2 V0 V1 BFMMLA
        V0 V2 16B MOVv
        FPCR X9 MSR
    ] alien-assembly ;
\ bmatmul { "bf16" } "required-arm64-features" set-word-prop

: hadd ( a b -- c )
    half-8 { half-8 half-8 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V0 V0 V1 FADDHv
        FPCR X9 MSR
    ] alien-assembly ;
\ hadd { "fp16" } "required-arm64-features" set-word-prop

: hsub ( a b -- c )
    half-8 { half-8 half-8 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V0 V0 V1 FSUBHv
        FPCR X9 MSR
    ] alien-assembly ;
\ hsub { "fp16" } "required-arm64-features" set-word-prop

: hmul ( a b -- c )
    half-8 { half-8 half-8 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V0 V0 V1 FMULHv
        FPCR X9 MSR
    ] alien-assembly ;
\ hmul { "fp16" } "required-arm64-features" set-word-prop

: hdiv ( a b -- c )
    half-8 { half-8 half-8 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V0 V0 V1 FDIVHv
        FPCR X9 MSR
    ] alien-assembly ;
\ hdiv { "fp16" } "required-arm64-features" set-word-prop

 : hfma ( a b c -- d )
    half-8 { half-8 half-8 half-8 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V2 V0 V1 FMLAHv V0 V2 16B MOVv
        FPCR X9 MSR
    ] alien-assembly ;
\ hfma { "fp16" } "required-arm64-features" set-word-prop

: hsqrt ( a -- b )
    half-8 { half-8 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V0 V0 FSQRTHv
        FPCR X9 MSR
    ] alien-assembly ;
\ hsqrt { "fp16" } "required-arm64-features" set-word-prop

: hpack ( lo hi -- b )
    half-8 { float-4 float-4 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V0 V0 FCVTNH V0 V1 FCVTNH2
        FPCR X9 MSR
    ] alien-assembly ;
\ hpack { "fp16" } "required-arm64-features" set-word-prop

: bpack ( lo hi -- b )
    bfloat-8 { float-4 float-4 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V0 V0 BFCVTN V0 V1 BFCVTN2
        FPCR X9 MSR
    ] alien-assembly ;
\ bpack { "bf16" } "required-arm64-features" set-word-prop

! Memory decoding canonicalizes NaNs before scalar min/max. Quiet half NaNs
! here too, so a signaling NaN plus a number selects the number on both paths.
<<
: quiet-half-nans ( reg -- )
    W11 0x7fff MOV V3 W11 8H DUP V3 over V3 16B ANDv
    W11 0x7c00 MOV V4 W11 8H DUP V3 V3 V4 8H CMHI
    W11 0x0200 MOV V4 W11 8H DUP V3 V3 V4 16B ANDv
    dup V3 16B ORRv ;
>>
: hmin ( a b -- c )
    half-8 { half-8 half-8 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V0 quiet-half-nans V1 quiet-half-nans
        V0 V0 V1 FMINNMHv
        FPCR X9 MSR
    ] alien-assembly ;
\ hmin { "fp16" } "required-arm64-features" set-word-prop
: hmax ( a b -- c )
    half-8 { half-8 half-8 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V0 quiet-half-nans V1 quiet-half-nans
        V0 V0 V1 FMAXNMHv
        FPCR X9 MSR
    ] alien-assembly ;
\ hmax { "fp16" } "required-arm64-features" set-word-prop
: heq ( a b -- c )
    half-8 { half-8 half-8 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V0 V0 V1 FCMEQHv
        FPCR X9 MSR
    ] alien-assembly ;
\ heq { "fp16" } "required-arm64-features" set-word-prop
: hgt ( a b -- c )
    half-8 { half-8 half-8 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V0 V0 V1 FCMGTHv
        FPCR X9 MSR
    ] alien-assembly ;
\ hgt { "fp16" } "required-arm64-features" set-word-prop
: hge ( a b -- c )
    half-8 { half-8 half-8 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V0 V0 V1 FCMGEHv
        FPCR X9 MSR
    ] alien-assembly ;
\ hge { "fp16" } "required-arm64-features" set-word-prop
: hlt ( a b -- c )
    half-8 { half-8 half-8 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V0 V1 V0 FCMGTHv
        FPCR X9 MSR
    ] alien-assembly ;
\ hlt { "fp16" } "required-arm64-features" set-word-prop
: hle ( a b -- c )
    half-8 { half-8 half-8 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V0 V1 V0 FCMGEHv
        FPCR X9 MSR
    ] alien-assembly ;
\ hle { "fp16" } "required-arm64-features" set-word-prop

: hunordered ( a b -- c )
    half-8 { half-8 half-8 } cdecl [
        X9 FPCR MRS X10 0x200 1 MOVZ FPCR X10 MSR
        V0 V0 V0 FCMEQHv V1 V1 V1 FCMEQHv
        V0 V0 V1 16B ANDv V0 V0 16B MVNv
        FPCR X9 MSR
    ] alien-assembly ;
\ hunordered { "fp16" } "required-arm64-features" set-word-prop
PRIVATE>

M:: arm.64 (vdot4+) ( a b c -- d )
    a uchar-16? b uchar-16? and [
        \ udot4 arm64-kernel-supported? [ a b c udot4 ] [ a b c call-next-method ] if
    ] [ a char-16? b char-16? and [
        \ sdot4 arm64-kernel-supported? [ a b c sdot4 ] [ a b c call-next-method ] if
    ] [
        \ usdot4 arm64-kernel-supported? [
            a uchar-16? [ a b c ] [ b a c ] if usdot4
        ] [ a b c call-next-method ] if
    ] if ] if ;

M:: arm.64 (vmatmul2x8+) ( a b c -- d )
    "i8mm" arm64-feature? [
        a uchar-16? b uchar-16? and [ a b c umatmul ] [
            a char-16? b char-16? and [ a b c smatmul ] [
                a uchar-16? [ a b c usmatmul ] [ a b c call-next-method ] if
            ] if
        ] if
    ] [ a b c call-next-method ] if ;

M: arm.64 (vbdot2+)
    \ bdot2 arm64-kernel-supported? [ bdot2 ] [ call-next-method ] if ;
M: arm.64 (vbmatmul2x4+)
    \ bmatmul arm64-kernel-supported? [ bmatmul ] [ call-next-method ] if ;
M:: arm.64 half-binary ( a b op -- result )
    "fp16" arm64-feature? a half-8? and b half-8? and [
        a b op {
            { "+" [ hadd ] } { "-" [ hsub ] } { "*" [ hmul ] } { "/" [ hdiv ] }
            { "min" [ hmin ] } { "max" [ hmax ] }
            { "=" [ heq ] } { "<" [ hlt ] } { "<=" [ hle ] }
            { ">" [ hgt ] } { ">=" [ hge ] } { "unordered" [ hunordered ] }
        } case
    ] [ a b op call-next-method ] if ;
M:: arm.64 half-fma ( a b c -- result )
    "fp16" arm64-feature? a half-8? and b half-8? and c half-8? and
    [ a b c hfma ] [ a b c call-next-method ] if ;
M: arm.64 half-sqrt
    "fp16" arm64-feature? [ hsqrt ] [ call-next-method ] if ;
M:: arm.64 pack-half ( lo hi -- result )
    "fp16" arm64-feature? lo float-4? and hi float-4? and
    [ lo hi hpack ] [ lo hi call-next-method ] if ;
M:: arm.64 pack-bfloat ( lo hi -- result )
    "bf16" arm64-feature? lo float-4? and hi float-4? and
    [ lo hi bpack ] [ lo hi call-next-method ] if ;
