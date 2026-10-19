! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax classes.struct kernel
math.floats.env.alpha unix ;
IN: math.floats.env.alpha.bsd
LIBRARY: libc
! NetBSD and OpenBSD machine/sysarch.h use the same FP_C interface.
CONSTANT: ALPHA_GET_FP_C 7
CONSTANT: ALPHA_SET_FP_C 8
FUNCTION-ALIAS: alpha-sysarch int sysarch ( int op, void* args )
M: alpha-env get-alpha-control
    alpha-control (struct) [ ALPHA_GET_FP_C swap [ alpha-sysarch ] unix-system-call drop ] keep
    control>> >>control drop ;
M: alpha-env set-alpha-control
    control>> alpha-control (struct) swap >>control
    ALPHA_SET_FP_C swap [ alpha-sysarch ] unix-system-call drop ;
