!:folding=none:collapseFolds=1:

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

IN: namespaces
DEFER: init-namespaces

IN: kernel
USE: arithmetic
USE: combinators
USE: errors
USE: lists
USE: logic
USE: namespaces
USE: stack
USE: strings
USE: vectors
USE: words

: hashcode ( obj -- hash )
    #! If two objects are =, they must have equal hashcodes.
    [
        [ cons? ] [ 4 cons-hashcode ]
        [ string? ] [ str-hashcode ]
        [ fixnum? ] [ ( return the object ) ]
        [ drop t ] [ drop 0 ]
    ] cond ;

: = ( obj obj -- ? )
    #! Push t if a is isomorphic to b.
    2dup eq? [
        2drop t
    ] [
        [
            [ cons? ] [ cons= ]
            [ string? ] [ str= ]
            [ drop t ] [ 2drop f ]
        ] cond
    ] ifte ;

: clone ( obj -- obj )
    [
        [ cons? ] [ clone-list ]
        [ vector? ] [ clone-vector ]
        [ drop t ] [ ( return the object ) ]
    ] cond ;

: class-of ( obj -- name )
    [
        [ fixnum? ] [ drop "fixnum" ]
        [ cons?   ] [ drop "cons" ]
        [ word?   ] [ drop "word" ]
        [ f =     ] [ drop "f" ]
        [ t =     ] [ drop "t" ]
        [ vector? ] [ drop "vector" ]
        [ string? ] [ drop "string" ]
        [ sbuf?   ] [ drop "sbuf" ]
        [ handle? ] [ drop "handle" ]
        [ drop t  ] [ drop "unknown" ]
    ] cond ;

: toplevel ( -- )
    init-namespaces
    init-errors
    0 <vector> set-datastack
    0 <vector> set-callstack ;

!!! HACK

IN: strings
: >upper ;
: >lower ;
IN: lists
: sort ;
