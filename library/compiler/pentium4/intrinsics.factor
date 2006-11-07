! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assembler generic kernel kernel-internals
math math-internals memory namespaces sequences words ;
IN: compiler

M: float-regs (%peek)
    drop
    fp-scratch swap %move-int>int
    fp-scratch %move-int>float ;

M: float-regs (%replace) drop swap %allot-float ;

! Floats
: define-float-op ( word op -- )
    [ [ "x" operand "y" operand ] % , ] [ ] make H{
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
    [
        [ end-basic-block "x" operand "y" operand UCOMISD ] % ,
    ] [ ] make H{
        { +input+ { { float "x" } { float "y" } } }
    } define-if-intrinsic ;

{
    { float< JB }
    { float<= JBE }
    { float> JA }
    { float>= JAE }
    { float= JE }
} [
    first2 define-float-jump
] each
