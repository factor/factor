! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax kernel math.floats.env.alpha ;
IN: math.floats.env.alpha.linux
LIBRARY: libm
FUNCTION: ulong __ieee_get_fp_control ( )
FUNCTION: void __ieee_set_fp_control ( ulong control )
M: alpha-env get-alpha-control
    __ieee_get_fp_control >>control drop ;
M: alpha-env set-alpha-control
    control>> __ieee_set_fp_control ;
