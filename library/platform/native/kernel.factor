! :folding=none:collapseFolds=1:

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

IN: vectors
DEFER: vector=

IN: kernel
USE: combinators
USE: errors
USE: io-internals
USE: lists
USE: logic
USE: math
USE: namespaces
USE: stack
USE: stdio
USE: strings
USE: vectors
USE: words
USE: unparser
USE: vectors

: hashcode ( obj -- hash )
    #! If two objects are =, they must have equal hashcodes.
    [
        [ cons? ] [ 4 cons-hashcode ]
        [ string? ] [ str-hashcode ]
        [ number? ] [ >fixnum ]
        [ drop t ] [ drop 0 ]
    ] cond ;

: = ( obj obj -- ? )
    #! Push t if a is isomorphic to b.
    2dup eq? [
        2drop t
    ] [
        [
            [ number? ] [ number= ]
            [ cons? ] [ cons= ]
            [ vector? ] [ vector= ]
            [ string? ] [ str= ]
            [ sbuf? ] [ sbuf= ]
            [ drop t ] [ 2drop f ]
        ] cond
    ] ifte ;

: clone ( obj -- obj )
    [
        [ cons? ] [ clone-list ]
        [ vector? ] [ vector-clone ]
        [ sbuf? ] [ sbuf-clone ]
        [ drop t ] [ ( return the object ) ]
    ] cond ;

: type-name ( n -- str )
    [
        [ 0 | "fixnum" ]
        [ 1 | "word" ]
        [ 2 | "cons" ]
        [ 4 | "ratio" ]
        [ 5 | "complex" ]
        [ 6 | "f" ]
        [ 7 | "t" ]
        [ 9 | "vector" ]
        [ 10 | "string" ]
        [ 11 | "sbuf" ]
        [ 12 | "port" ]
        [ 13 | "bignum" ]
        [ 14 | "float" ]
        ! These values are only used by the kernel for error
        ! reporting.
        [ 100 | "fixnum/bignum" ]
        [ 101 | "fixnum/bignum/ratio" ]
        [ 102 | "fixnum/bignum/ratio/float" ]
        [ 103 | "fixnum/bignum/ratio/float/complex" ]
        [ 104 | "fixnum/string" ]
    ] assoc ;

: java? f ;
: native? t ;

! No compiler...
: inline ;
: interpret-only ;

! HACKS

IN: strings
: char? drop f ;
: >char ;
: >upper ;
: >lower ;
