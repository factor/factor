! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types kernel math namespaces
cpu.architecture cpu.arm.architecture cpu.arm.assembler
cpu.arm.intrinsics generator generator.registers continuations
compiler io vocabs.loader sequences system ;

! EABI passes floats in integer registers.
[ alien-float ]
[ >r >r >float r> r> set-alien-float ]
4
"box_float"
"to_float" <primitive-type>
"float" define-primitive-type

[ >float ] "float" c-type set-c-type-prep

[ alien-double ]
[ >r >r >float r> r> set-alien-double ]
8
"box_double"
"to_double" <primitive-type> <long-long-type>
"double" define-primitive-type

[ >float ] "double" c-type set-c-type-prep

T{ arm-backend } compiler-backend set-global

! We don't auto-detect since that would require us to support
! illegal instruction traps. This works on Linux but not on
! Windows CE.

"arm-variant" get [
    "ARM variant: " write "arm-variant" get print
] [
    "==========" print
    "You should specify the -arm-variant=<variant> switch." print
    "<variant> can be one of arm3, arm4, arm4t, or arm5." print
    "Assuming arm3." print
    "==========" print
    "arm3" "arm-variant" set-global
] if

"arm-variant" get { "arm4" "arm4t" "arm5" } member? [
    "cpu.arm.4" require
] when

"arm-variant" get { "arm4t" "arm5" } member? [
    t have-BX? set-global
] when

"arm-variant" get "arm5" = [
    t have-BLX? set-global
] when

7 cells profiler-prologues set-global
