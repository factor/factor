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
USE: arithmetic
USE: combinators
USE: kernel
USE: lists
USE: logic
USE: stack

: multiplier ( n -- 2|4 )
    odd? 4 2 ? ;

: (multipliers) ( list n -- list )
    dup 2 <= [
        drop
    ] [
        dup >r multiplier swons r> pred (multipliers)
    ] ifte ;

: multipliers ( n -- list )
    #! The value n must be odd. Makes a list like [ 1 4 2 4 1 ]
    [ 1 ] swap (multipliers) 1 swons ;

: x-values ( lower upper n -- list )
    #! The value n must be odd.
    pred >r over - r> dup succ count [
        >r 3dup r> swap / * +
    ] map >r 3drop r> ;

: y-values ( lower upper n quot -- values )
    >r x-values r> map ;

: (simpson) ( lower upper n quot -- value )
    over multipliers >r y-values r> *|+ ;

: h ( lower upper n -- h )
    transp - swap pred / 3 / ;

: simpson ( lower upper n quot -- value )
    #! Compute the integral between the lower and upper bound,
    #! using Simpson's method with n steps. The value of n must
    #! be odd. The quotation must have stack effect
    #! ( x -- f(x) ).
    >r 3dup r> (simpson) >r h r> * ;
