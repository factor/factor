! :folding=indent:collapseFolds=0:

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

IN: random
USE: combinators
USE: kernel
USE: lists
USE: math
USE: stack

: random-digit ( -- digit )
    0 9 random-int ;

: random-symmetric-int ( max -- random )
    #! Return a random integer between -max and max.
    dup neg swap random-int ;

: chance ( n -- boolean )
    #! Returns true with a 1/n probability, false with a (n-1)/n
    #! probability.
    1 swap random-int 1 = ;

: random-element ( list -- random )
    #! Returns a random element from the given list.
    dup >r length pred 0 swap random-int r> nth ;

: random-subset ( list -- list )
    #! Returns a random subset of the given list. Each item is
    #! chosen with a 50%
    #! probability.
    [ drop random-boolean ] subset ;

: car+ ( list -- sum )
    #! Adds the car of each element of the given list.
    0 swap [ car + ] each ;

: random-probability ( list -- sum )
    #! Adds the car of each element of the given list, and
    #! returns a random number between 1 and this sum.
    1 swap car+ random-int ;

: random-element-iter ( list index -- elem )
    #! Used by random-element*. Do not call directly.
    [ unswons unswons ] dip ( list elem probability index )
    swap -                  ( list elem index )
    dup 0 <= [
        drop nip
    ] [
        nip random-element-iter
    ] ifte ;

: random-element* ( list -- elem )
    #! Returns a random element of the given list of comma
    #! pairs. The car of each pair is a probability, the cdr is
    #! the item itself. Only the cdr of the comma pair is
    #! returned.
    dup 1 swap car+ random-int random-element-iter ;

: random-subset* ( list -- list )
    #! Returns a random subset of the given list of comma pairs.
    #! The car of each pair is a probability, the cdr is the
    #! item itself. Only the cdr of the comma pair is returned.
    dup [ [ [ ] ] dip car+ ] dip ( [ ] probabilitySum list )
    [
        [ 1 over random-int ] dip ( [ ] probabilitySum probability elem )
        uncons ( [ ] probabilitySum probability elema elemd )
        -rot ( [ ] probabilitySum elemd probability elema )
        > ( [ ] probabilitySum elemd boolean )
        [
            drop
        ] [
            -rot ( elemd [ ] probabilitySum )
            [ cons ] dip ( [ elemd ] probabilitySum )
        ] ifte
    ] each drop ;
