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
DEFER: vector-hashcode

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

! The 'fake vtable' used here speeds things up a lot.
! It is quite clumsy, however. A higher-level CLOS-style
! 'generic words' system will be built later.

: generic ( obj vtable -- )
    >r dup type r> vector-nth execute ;

: 2generic ( n n vtable -- )
    >r 2dup arithmetic-type r> vector-nth execute ;

: default-hashcode drop 0 ;

: hashcode ( obj -- hash )
    #! If two objects are =, they must have equal hashcodes.
    {
        nop
        word-hashcode
        cons-hashcode
        default-hashcode
        >fixnum
        >fixnum
        default-hashcode
        default-hashcode
        default-hashcode
        vector-hashcode
        str-hashcode
        sbuf-hashcode
        default-hashcode
        >fixnum
        >fixnum
        default-hashcode
        default-hashcode
    } generic ;

IN: math DEFER: number= ( defined later... )
IN: kernel
: = ( obj obj -- ? )
    #! Push t if a is isomorphic to b.
    {
        number=
        eq?
        cons=
        eq?
        number=
        number=
        eq?
        eq?
        eq?
        vector=
        str=
        sbuf=
        eq?
        number=
        number=
        eq?
        eq?
    } generic ;

: 2= ( a b c d -- ? )
    #! Test if a = c, b = d.
    swapd = [ = ] [ 2drop f ] ifte ;

: clone ( obj -- obj )
    [
        [ cons? ] [ clone-list ]
        [ vector? ] [ vector-clone ]
        [ sbuf? ] [ sbuf-clone ]
        [ drop t ] [ ( return the object ) ]
    ] cond ;

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
