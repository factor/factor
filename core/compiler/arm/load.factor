PROVIDE: core/compiler/arm
{ +files+ {
    "assembler.factor"
    "architecture.factor"
    "allot.factor"
    "intrinsics.factor"
} }
{ +tests+ {
    "test.factor"
} } ;

! EABI passes floats in integer registers.
USING: alien generator kernel math ;

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
