! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assembler generic kernel kernel-internals
lists math math-internals memory namespaces sequences words ;
IN: compiler

M: float-regs (%peek) ( vreg loc reg-class -- )
    drop
    fp-scratch swap %move-int>int
    fp-scratch %move-int>float ;

: load-zone-ptr ( vreg -- )
    #! Load pointer to start of zone array
    "generations" f 2dup dlsym [] MOV rel-dlsym ;

: load-allot-ptr ( vreg -- )
    dup load-zone-ptr dup cell [+] MOV ;

: inc-allot-ptr ( vreg n -- )
    >r dup load-zone-ptr cell [+] r> ADD ;

: with-inline-alloc ( vreg prequot postquot spec -- )
    #! both quotations are called with the vreg
    [
        >r >r v>operand dup load-allot-ptr
        dup [] \ tag-header get call tag-header MOV
        r> over slip dup \ tag get call OR
        r> over slip \ size get call inc-allot-ptr
    ] bind ; inline

M: float-regs (%replace) ( vreg loc reg-class -- )
    drop fp-scratch
    [ 8 [+] rot v>operand MOVSD ]
    [ >r v>operand r> MOV ] H{
        { tag-header [ float-tag ] }
        { tag [ float-tag ] }
        { size [ 16 ] }
    } with-inline-alloc ;

! Floats
: define-float-op ( word op -- )
    [ [ "x" operand "y" operand ] % , ] [ ] make H{
        { +input { { float "x" } { float "y" } } }
        { +output { "x" } }
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
        [ end-basic-block "x" operand "y" operand COMISD ] % ,
    ] [ ] make H{
        { +input { { float "x" } { float "y" } } }
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
