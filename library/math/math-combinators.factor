! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
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

: times ( n quot -- )
    #! Evaluate a quotation n times.
    #!
    #! In order to compile, the code must produce as many values
    #! as it consumes.
    tuck >r dup 0 <= [ r> 3drop ] [ 1 - slip r> times ] ifte ;
    inline

: (times) ( limit n quot -- )
    pick pick <= [
        3drop
    ] [
        rot pick 1 + pick 3slip (times)
    ] ifte ; inline

: times* ( n quot -- )
    #! Evaluate a quotation n times, pushing the index at each
    #! iteration. The index ranges from 0 to n-1.
    #!
    #! In order to compile, the code must consume one more value
    #! than it produces.
    0 swap (times) ; inline

: fac ( n -- n! )
    1 swap [ 1 + * ] times* ;

: 2times-succ ( #{ a b } #{ c d } -- z )
    #! Lexicographically add #{ 0 1 } to a complex number.
    #! If d + 1 == b, return #{ c+1 0 }. Otherwise, #{ c d+1 }.
    2dup imaginary 1 + swap imaginary = [
        nip real 1 +
    ] [
        nip >rect 1 + rect>
    ] ifte ; inline

: 2times<= ( #{ a b } #{ c d } -- ? )
    swap real swap real <= ; inline

: (2times) ( limit n quot -- )
    pick pick 2times<= [
        3drop
    ] [
        rot pick dupd 2times-succ pick 3slip (2times)
    ] ifte ; inline

: 2times* ( #{ w h } quot -- )
    #! Apply a quotation to each pair of complex numbers
    #! #{ a b } such that a < w, b < h.
    0 swap (2times) ; inline

: (repeat) ( i n quot -- )
    pick pick >= [
        3drop
    ] [
        [ swap >r call 1 + r> ] keep (repeat)
    ] ifte ;

: repeat ( n quot -- )
    #! Execute a quotation n times. The loop counter is kept on
    #! the stack, and ranges from 0 to n-1.
    0 -rot (repeat) ;
