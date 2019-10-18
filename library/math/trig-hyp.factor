! :folding=indent:collapseFolds=0:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: math
USE: kernel
USE: math
USE: math-internals

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
