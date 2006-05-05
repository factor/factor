! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assembler kernel kernel-internals lists math
math-internals namespaces sequences words ;
IN: compiler

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
