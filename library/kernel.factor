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
USE: lists
USE: math
USE: math-internals
USE: strings
USE: vectors
USE: words
USE: vectors

: cpu ( -- arch )
    #! Returns one of "x86" or "unknown".
    7 getenv ;

: os ( -- arch )
    #! Returns one of "unix" or "win32".
    11 getenv ;

! The 'fake vtable' used here speeds things up a lot.
! It is quite clumsy, however. A higher-level CLOS-style
! 'generic words' system will be built later.

: dispatch ( n vtable -- )
    vector-nth call ;

: generic ( obj vtable -- )
    >r dup type r> dispatch ; inline

: 2generic ( n n vtable -- )
    >r 2dup arithmetic-type r> dispatch ; inline

: hashcode ( obj -- hash )
    #! If two objects are =, they must have equal hashcodes.
    {
        [               ] ! 0
        [ word-hashcode     ] ! 1
        [ cons-hashcode     ] ! 2
        [ drop 0  ] ! 3
        [ >fixnum           ] ! 4
        [ >fixnum           ] ! 5
        [ drop 0  ] ! 6
        [ drop 0  ] ! 7
        [ drop 0  ] ! 8
        [ >fixnum           ] ! 9 
        [ >fixnum           ] ! 10
        [ vector-hashcode   ] ! 11
        [ str-hashcode      ] ! 12
        [ sbuf-hashcode     ] ! 13
        [ drop 0  ] ! 14
        [ drop 0  ] ! 15
        [ drop 0  ] ! 16
    } generic ;

IN: math DEFER: number= ( defined later... )
IN: kernel
: = ( obj obj -- ? )
    #! Push t if a is isomorphic to b.
    {
        [ number= ] ! 0
        [ eq?     ] ! 1
        [ cons=   ] ! 2
        [ eq?     ] ! 3
        [ number= ] ! 4
        [ number= ] ! 5
        [ eq?     ] ! 6
        [ eq?     ] ! 7
        [ eq?     ] ! 8
        [ number= ] ! 9 
        [ number= ] ! 10
        [ vector= ] ! 11
        [ str=    ] ! 12
        [ sbuf=   ] ! 13
        [ eq?     ] ! 14
        [ eq?     ] ! 15 
        [ eq?     ] ! 16
    } generic ; 

: set-boot ( quot -- )
    #! Set the boot quotation.
    8 setenv ;
