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

IN: errors
DEFER: throw

IN: math-internals
USE: generic
USE: kernel
USE: kernel-internals
USE: math

: (rect>) ( xr xi -- x )
    #! Does not perform a check that the arguments are reals.
    #! Do not use in your own code.
    dup 0 number= [ drop ] [ <complex> ] ifte ; inline

IN: math

GENERIC: real ( #{ re im }# -- re )
M: real real ;
M: complex real 0 slot %real ;

GENERIC: imaginary ( #{ re im }# -- im )
M: real imaginary drop 0 ;
M: complex imaginary 1 slot %real ;

: rect> ( xr xi -- x )
    over real? over real? and [
        (rect>)
    ] [
        "Complex number must have real components" throw drop
    ] ifte ; inline

: >rect ( x -- xr xi ) dup real swap imaginary ; inline

: conjugate ( z -- z* )
    >rect neg rect> ;

: arg ( z -- arg )
    #! Compute the complex argument.
    >rect swap fatan2 ;

: >polar ( z -- abs arg )
    dup abs swap >rect swap fatan2 ;

: cis ( theta -- cis )
    dup fcos swap fsin rect> ;

: polar> ( abs arg -- z )
    cis * ;

: absq >rect swap sq swap sq + ;

: dot ( #{ x1 x2 }# #{ y1 y2 }# -- x1*y1+x2*y2 )
    over real over real * >r swap imaginary swap imaginary * r>
    + ;

: proj ( u v -- w )
    #! Orthogonal projection of u onto v.
    [ [ dot ] keep absq /f ] keep * ;

IN: math-internals

: 2>rect ( x y -- xr yr xi yi )
    [ swap real swap real ] 2keep
    swap imaginary swap imaginary ; inline

M: complex number= ( x y -- ? )
    2>rect number= [ number= ] [ 2drop f ] ifte ;

: *re ( x y -- xr*yr xi*ri ) 2>rect * >r * r> ; inline
: *im ( x y -- xi*yr xr*yi ) 2>rect >r * swap r> * ; inline

M: complex + 2>rect + >r + r> (rect>) ;
M: complex - 2>rect - >r - r> (rect>) ;
M: complex * ( x y -- x*y ) 2dup *re - -rot *im + (rect>) ;

: complex/ ( x y -- r i m )
    #! r = xr*yr+xi*yi, i = xi*yr-xr*yi, m = yr*yr+yi*yi
    dup absq >r 2dup *re + -rot *im - r> ; inline

M: complex / ( x y -- x/y ) complex/ tuck / >r / r> (rect>) ;
M: complex /f ( x y -- x/y ) complex/ tuck /f >r /f r> (rect>) ;

M: complex abs ( z -- |z| ) absq fsqrt ;

M: complex hashcode ( n -- n )
    >rect >fixnum swap >fixnum bitxor ;
