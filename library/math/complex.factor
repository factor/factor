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
USE: generic
USE: kernel
USE: math
USE: math-internals

: >rect ( x -- xr xi ) dup real swap imaginary ; inline

: conjugate ( z -- z* )
    >rect neg rect> ;

: arg ( z -- arg )
    #! Compute the complex argument.
    >rect swap fatan2 ;

: >polar ( z -- abs arg )
    >rect 2dup swap fatan2 >r mag2 r> ;

: cis ( theta -- cis )
    dup fcos swap fsin rect> ;

: polar> ( abs arg -- z )
    cis * ;

IN: math-internals

: 2>rect ( x y -- xr yr xi yi )
    [ swap real swap real ] 2keep
    swap imaginary swap imaginary ; inline

M: complex number= ( x y -- ? )
    2>rect number= [ number= ] [ 2drop f ] ifte ;

: *re ( x y -- xr*yr xi*ri ) 2>rect * >r * r> ; inline
: *im ( x y -- xi*yr xr*yi ) 2>rect >r * swap r> * ; inline

M: complex + 2>rect + >r + r> rect> ;
M: complex - 2>rect - >r - r> rect> ;
M: complex * ( x y -- x*y ) 2dup *re - -rot *im + rect> ;

: abs^2 ( x -- y ) >rect sq swap sq + ; inline
: complex/ ( x y -- r i m )
    #! r = xr*yr+xi*yi, i = xi*yr-xr*yi, m = yr*yr+yi*yi
    dup abs^2 >r 2dup *re + -rot *im - r> ; inline

M: complex / ( x y -- x/y ) complex/ tuck / >r / r> rect> ;
M: complex /f ( x y -- x/y ) complex/ tuck /f >r /f r> rect> ;

M: complex abs ( z -- |z| ) >rect mag2 ;

M: complex hashcode ( n -- n )
    >rect >fixnum swap >fixnum bitxor ;
