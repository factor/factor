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
USE: kernel-internals
USE: math
USE: math-internals

GENERIC: numerator ( a/b -- a )
M: integer numerator ;
M: ratio numerator 0 slot ;

GENERIC: denominator ( a/b -- b )
M: integer denominator drop 1 ;
M: ratio denominator 1 slot ;

IN: math-internals

: 2>fraction ( a/b c/d -- a c b d )
    [ swap numerator swap numerator ] 2keep
    swap denominator swap denominator ; inline

M: ratio number= ( a/b c/d -- ? )
    2>fraction number= [ number= ] [ 2drop f ] ifte ;

: scale ( a/b c/d -- a*d b*c )
    2>fraction >r * swap r> * swap ; inline

: ratio+d ( a/b c/d -- b*d )
    denominator swap denominator * ; inline

M: ratio < scale < ;
M: ratio <= scale <= ;
M: ratio > scale > ;
M: ratio >= scale >= ;

M: ratio + ( x y -- x+y ) 2dup scale + -rot ratio+d integer/ ;
M: ratio - ( x y -- x-y ) 2dup scale - -rot ratio+d integer/ ;
M: ratio * ( x y -- x*y ) 2>fraction * >r * r> integer/ ;
M: ratio / scale integer/ ;
M: ratio /i scale /i ;
M: ratio /f scale /f ;
