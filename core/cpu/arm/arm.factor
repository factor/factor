USING: alien alien.c-types kernel math namespaces
cpu.architecture cpu.arm.architecture cpu.arm.intrinsics
generator generator.registers continuations compiler io
vocabs.loader ;

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

: (detect-arm5) ;

\ (detect-arm5) [
    ! The LDRH word is defined in the module we conditionally
    ! load below...
    ! R0 PC 0 <+> LDRH
    HEX: e1df00b0 ,
] H{
    { +scratch+ { { 0 "scratch" } } }
} define-intrinsic

: detect-arm5 (detect-arm5) ;

: arm5? ( -- ? ) [ detect-arm5 ] catch not ;

"arm-variant" get [
    \ detect-arm5 compile
    "Detecting ARM architecture variant..." print
    arm5? "arm5" "arm3" ? "arm-variant" set
] unless

"ARM architecture variant: " write "arm-variant" get print

"arm-variant" "arm5" = [ "cpu.arm5" require ] when
