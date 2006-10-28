! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assembler generic kernel kernel-internals
math math-internals memory namespaces sequences words ;
IN: compiler

M: float-regs (%peek)
    drop
    fp-scratch swap %move-int>int
    fp-scratch %move-int>float ;

: load-zone-ptr ( vreg -- )
    #! Load pointer to start of zone array
    dup "generations" f [ dlsym MOV ] 2keep
    rel-absolute-cell rel-dlsym
    dup [] MOV ;

: load-allot-ptr ( vreg -- )
    dup load-zone-ptr dup cell [+] MOV ;

: inc-allot-ptr ( vreg n -- )
    >r dup load-zone-ptr cell [+] r> ADD ;

: with-inline-alloc ( prequot postquot spec -- )
    #! both quotations are called with the vreg
    [
        alloc-tmp-reg PUSH
        alloc-tmp-reg load-allot-ptr
        alloc-tmp-reg [] \ tag-header get call tag-header MOV
        >r call alloc-tmp-reg \ tag get call OR
        r> call alloc-tmp-reg \ size get call inc-allot-ptr
        alloc-tmp-reg POP
    ] bind ; inline

M: float-regs (%replace)
    drop
    [ alloc-tmp-reg 8 [+] rot v>operand MOVSD ]
    [ v>operand alloc-tmp-reg MOV ] H{
        { tag-header [ float-tag ] }
        { tag [ float-tag ] }
        { size [ 16 ] }
    } with-inline-alloc ;

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
