! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
REQUIRES: core/compiler/x86 ;
USING: alien arrays assembler-x86 generic kernel
kernel-internals math math-internals memory namespaces sequences
words errors ;
IN: generator

M: float-regs (%peek)
    drop
    temp-reg v>operand PUSH
    temp-reg swap %move-int>int
    temp-reg %move-int>float
    temp-reg v>operand POP ;

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
} define-intrinsic

PROVIDE: core/compiler/x86/sse2 ;
