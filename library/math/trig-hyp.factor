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
    fsinh swap fsin neg * rect> ; inline

: sec cos recip ; inline

: cosh ( z -- cosh )
    >rect 2dup
    fcos swap fcosh * -rot
    fsin swap fsinh * rect> ; inline

: sech cosh recip ; inline

: sin ( z -- sin )
    >rect 2dup
    fcosh swap fsin * -rot
    fsinh swap fcos * rect> ; inline

: cosec sin recip ; inline

: sinh ( z -- sinh )
    >rect 2dup
    fcos swap fsinh * -rot
    fsin swap fcosh * rect> ; inline

: cosech sinh recip ; inline

: tan dup sin swap cos / ; inline
: tanh dup sinh swap cosh / ; inline
: cot dup cos swap sin / ; inline
: coth dup cosh swap sinh / ; inline
