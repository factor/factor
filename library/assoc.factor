! :folding=indent:collapseFolds=1:

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

IN: lists
USE: logic
USE: combinators
USE: kernel
USE: stack

: assoc? ( list -- ? )
    #! Push if the list appears to be an alist (each element is
    #! a cons).
    dup list? [ [ cons? ] all? ] [ drop f ] ifte ;

: assoc* ( key alist -- [ key | value ] )
    #! Looks up the key in an alist. Push the key/value pair.
    #! Most of the time you want to use assoc not assoc*.
    dup [
        2dup car car = [
            nip car
        ] [
            cdr assoc*
        ] ifte
    ] [
        2drop f
    ] ifte ;

: assoc ( key alist -- value )
    #! Looks up the key in an alist. An alist is a proper list
    #! of comma pairs, the car of each pair is a key, the cdr is
    #! the value. For example:
    #! [ [ 1 | "one" ] [ 2 | "two" ] [ 3 | "three" ] ]
    assoc* dup [ cdr ] when ;

: acons ( value key alist -- alist )
    >r swons r> cons ;

: set-assoc ( value key alist -- alist )
    #! Sets the key in the alist. Does not modify the existing
    #! list by consing a new key/value pair onto the alist. The
    #! newly-added pair 'shadows' the previous value.
    [ dupd car = not ] subset acons ;
