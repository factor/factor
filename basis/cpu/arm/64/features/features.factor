! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: init kernel memoize namespaces sequences sets system vocabs vocabs.loader words ;
IN: cpu.arm.64.features

! Detected capabilities are process-local, never a claim about the machine
! loading a saved image. Optional opcodes live in private, non-inline kernels.
SYMBOL: disabled-arm64-features
CONSTANT: optional-arm64-features { "dotprod" "fp16" "bf16" "i8mm" }
HOOK: probe-arm64-features os ( -- features )
M: object probe-arm64-features { } ;
MEMO: detected-arm64-features ( -- features )
    cpu arm.64? [ probe-arm64-features ] [ { } ] if ;

: arm64-features ( -- features )
    "disable-neon-extensions" get [ { } ] [
        detected-arm64-features disabled-arm64-features get diff
    ] if ;

: arm64-feature? ( feature -- ? ) arm64-features member? ;
: arm64-features-supported? ( features -- ? ) arm64-features subset? ;

: arm64-kernel-requirements ( word -- features )
    "required-arm64-features" word-prop { } or ;
: arm64-kernel-supported? ( word -- ? )
    arm64-kernel-requirements arm64-features-supported? ;

STARTUP-HOOK: [ \ detected-arm64-features reset-memoized ]

os macos? [ "cpu.arm.64.features.macos" require ] when
os linux? [ "cpu.arm.64.features.linux" require ] when
os windows? [ "cpu.arm.64.features.windows" require ] when
