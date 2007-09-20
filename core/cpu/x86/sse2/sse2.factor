! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays cpu.x86.assembler cpu.x86.architecture
generic kernel kernel.private math math.private memory
namespaces sequences words generator generator.registers
cpu.architecture math.floats.private layouts quotations ;
IN: cpu.x86.sse2

M: float-regs (%peek)
    drop
    temp-reg swap %move-int>int
    temp-reg %move-int>float ;

M: float-regs (%replace) drop swap %move-float>int ;

: define-float-op ( word op -- )
    [ "x" operand "y" operand ] swap add H{
        { +input+ { { float "x" } { float "y" } } }
        { +output+ { "x" } }
    } define-intrinsic ;

{
    { float+ ADDSD }
    { float- SUBSD }
    { float* MULSD }
    { float/f DIVSD }
} [
    first2 define-float-op
] each

: define-float-jump ( word op -- )
    [ "x" operand "y" operand UCOMISD ] swap add
    { { float "x" } { float "y" } } define-if-intrinsic ;

{
    { float< JB }
    { float<= JBE }
    { float> JA }
    { float>= JAE }
    { float= JE }
} [
    first2 define-float-jump
] each

\ float>fixnum [
    "out" operand "in" operand CVTTSD2SI
    "out" operand tag-bits get SHL
] H{
    { +input+ { { float "in" } } }
    { +scratch+ { { f "out" } } }
    { +output+ { "out" } }
} define-intrinsic

\ fixnum>float [
    "in" operand %untag-fixnum
    "out" operand "in" operand CVTSI2SD
] H{
    { +input+ { { f "in" } } }
    { +scratch+ { { float "out" } } }
    { +output+ { "out" } }
    { +clobber+ { "in" } }
} define-intrinsic

: %alien-float-get ( quot -- )
    "offset" operand %untag-fixnum
    "output" operand "alien" operand-class %alien-accessor ;
    inline

: alien-float-get-template
    H{
        { +input+ {
            { f "alien" simple-c-ptr }
            { f "offset" fixnum }
        } }
        { +scratch+ { { float "output" } } }
        { +output+ { "output" } }
        { +clobber+ { "alien" "offset" } }
    } ;

: %alien-float-set ( quot -- )
    "offset" operand %untag-fixnum
    "value" operand "alien" operand-class %alien-accessor ;
    inline

: alien-float-set-template
    H{
        { +input+ {
            { float "value" float }
            { f "alien" simple-c-ptr }
            { f "offset" fixnum }
        } }
        { +clobber+ { "value" "alien" "offset" } }
    } ;

: define-alien-float-intrinsics ( word get-quot word set-quot -- )
    [ %alien-float-set ] curry
    alien-float-set-template
    define-intrinsic
    [ %alien-float-get ] curry
    alien-float-get-template
    define-intrinsic ;

\ alien-double
[ MOVSD ]
\ set-alien-double
[ swap MOVSD ]
define-alien-float-intrinsics

\ alien-float
[ dupd MOVSS dup CVTSS2SD ]
\ set-alien-float
[ swap dup dup CVTSD2SS MOVSS ]
define-alien-float-intrinsics
