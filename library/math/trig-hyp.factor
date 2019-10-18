! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: kernel math math-internals ;

! Trigonometric functions:
!    cos sec sin cosec tan cot

! Hyperbolic functions:
!    cosh sech sinh cosech tanh coth

: cos ( z -- cos )
    >rect 2dup
    fcosh swap fcos * -rot
    fsinh swap fsin neg * rect> ;

: sec cos recip ;

: cosh ( z -- cosh )
    >rect 2dup
    fcos swap fcosh * -rot
    fsin swap fsinh * rect> ;

: sech cosh recip ;

: sin ( z -- sin )
    >rect 2dup
    fcosh swap fsin * -rot
    fsinh swap fcos * rect> ;

: cosec sin recip ;

: sinh ( z -- sinh )
    >rect 2dup
    fcos swap fsinh * -rot
    fsin swap fcosh * rect> ;

: cosech sinh recip ;

: tan dup sin swap cos / ;
: tanh dup sinh swap cosh / ;
: cot dup cos swap sin / ;
: coth dup cosh swap sinh / ;
