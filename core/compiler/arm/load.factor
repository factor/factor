PROVIDE: core/compiler/arm
{ +files+ {
    "assembler.factor"
    "architecture.factor"
    "intrinsics.factor"
} }
{ +tests+ {
    "test.factor"
} } ;

! EABI passes floats in integer registers.
USING: alien generator ;

T{ int-regs } "double" c-type set-c-type-reg-class
T{ int-regs } "float" c-type set-c-type-reg-class
