! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assembler generic kernel kernel-internals
lists math math-internals memory namespaces sequences words ;
IN: compiler

: literal-template
    #! floats map to 'float' so we put float literals in float
    #! vregs
    [ class ] map ;

: load-zone-ptr ( vreg -- )
    #! Load pointer to start of zone array
    "generations" f dlsym [] MOV ;

: load-allot-ptr ( vreg -- )
    dup load-zone-ptr dup cell [+] MOV ;

: inc-allot-ptr ( vreg n -- )
    >r dup load-zone-ptr cell [+] r> ADD ;

: with-inline-alloc ( vreg spec prequot postquot -- )
    #! both quotations are called with the vreg
    rot [
        >r >r v>operand dup load-allot-ptr
        dup [] \ tag-header get call tag-header MOV
        r> over slip dup \ tag get call OR
        r> over slip \ size get call inc-allot-ptr
    ] bind ; inline

M: float-regs (%replace) ( vreg loc reg-class -- )
    drop fp-scratch H{
        { tag-header [ float-tag ] }
        { tag [ float-tag ] }
        { size [ 16 ] }
    } [ 8 [+] rot v>operand MOVSD ]
    [ >r v>operand r> MOV ] with-inline-alloc ;

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
    { float< JL }
    { float<= JLE }
    { float> JG }
    { float>= JGE }
    { float= JE }
} [
    first2 define-float-jump
] each
