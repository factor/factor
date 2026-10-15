! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.syntax continuations kernel
libc math math.bitwise math.floats.env.ppc system unix ;
IN: math.floats.env.ppc.linux

LIBRARY: libc
FUNCTION: int prctl ( int option, ulong arg2, ulong arg3, ulong arg4, ulong arg5 )

CONSTANT: PR_SET_FPEXC 12
CONSTANT: PR_FP_EXC_PRECISE 3

<PRIVATE

CONSTANT: PR_GET_FPEXC 11
FUNCTION-ALIAS: get-ppc-fp-exception-mode int prctl
    ( int option, uint* mode, ulong arg3, ulong arg4, ulong arg5 )

: ppc-fp-exception-mode-supported? ( -- ? )
    [
        PR_GET_FPEXC 0 uint <ref> 0 0 0
        [ get-ppc-fp-exception-mode ] unix-system-call drop t
    ] [
        dup unix-system-call-error?
        [ dup errno>> dup EINVAL = swap ENOSYS = or ] [ f ] if
        [ drop f ] [ rethrow ] if
    ] recover ;

PRIVATE>

! Linux controls exception delivery separately from the FPSCR enable bits.
! The setting belongs to the current native thread and cannot be saved in an image.
! User emulators can deliver FPSCR traps directly without implementing this
! Linux-specific mode API. Query it before setting it; keep native traps enabled.
M: linux ppc-set-fp-exception-mode
    fpscr>> ppc-fp-traps-bits mask zero? [
        ppc-fp-exception-mode-supported? [
            PR_SET_FPEXC PR_FP_EXC_PRECISE 0 0 0 [ prctl ] unix-system-call drop
        ] when
    ] unless ;
