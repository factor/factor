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

IN: compiler
USE: alien
USE: combinators
USE: inference
USE: errors
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: stack
USE: strings
USE: words
USE: vectors

: LITERAL ( cell -- )
    #! Push literal on data stack.
    4 ESI R+I
    ESI I>[R] ;

: [LITERAL] ( cell -- )
    #! Push complex literal on data stack by following an
    #! indirect pointer.
    4 ESI R+I
    EAX [I]>R
    EAX ESI R>[R] ;

: immediate? ( obj -- ? )
    #! fixnums and f have a pointerless representation, and
    #! are compiled immediately. Everything else can be moved
    #! by GC, and is indexed through a table.
    dup fixnum? swap f eq? or ;

: compile-literal ( obj -- )
    dup immediate? [
        address LITERAL
    ] [
        intern-literal [LITERAL]
    ] ifte ;

: PUSH-DS ( -- )
    #! Push contents of EAX onto datastack.
    4 ESI R+I
    EAX ESI R>[R] ;

: POP-DS ( -- )
    #! Pop datastack, store pointer to datastack top in EAX.
    ESI EAX [R]>R
    4 ESI R-I ;

: SELF-CALL ( name -- )
    #! Call named C function in Factor interpreter executable.
    dlsym-self CALL JUMP-FIXUP ;

#push [ compile-literal ] "generator" set-word-property

#call [
    dup postpone-word
    CALL compiled-offset defer-xt
] "generator" set-word-property

#call-label [
    CALL compiled-offset defer-xt
] "generator" set-word-property

#jump-label [
    JUMP compiled-offset defer-xt
] "generator" set-word-property

#jump-label-t [
    POP-DS
    ! condition is now in EAX
    f address EAX CMP-I-R
    ! jump w/ address added later
    JNE compiled-offset defer-xt
] "generator" set-word-property

#return-to [
    PUSH-I/PARTIAL 0 defer-xt
] "generator" set-word-property

#return [ drop RET ] "generator" set-word-property

#drop [ drop  4 ESI R-I ] "generator" set-word-property
#dup [
    drop
    ESI EAX [R]>R
    4 ESI R+I
    EAX ESI R>[R]
] "generator" set-word-property

! This is crap
#swap [ drop \ swap CALL compiled-offset defer-xt ] "generator" set-word-property
#over [ drop \ over CALL compiled-offset defer-xt ] "generator" set-word-property
#pick [ drop \ pick CALL compiled-offset defer-xt ] "generator" set-word-property
#>r [ drop \ >r CALL compiled-offset defer-xt ] "generator" set-word-property
#r> [ drop \ r> CALL compiled-offset defer-xt ] "generator" set-word-property

: begin-jump-table ( -- )
    #! Compile a piece of code that jumps to an offset in a
    #! jump table indexed by the type of the Factor object in
    #! EAX.
    #! The jump table must immediately follow this macro.
    2 EAX R<<I ( -- fixup )
    EAX+/PARTIAL
    EAX JUMP-[R]
    cell compile-aligned
    compiled-offset swap set-compiled-cell ( fixup -- ) ;

: jump-table-entry ( word -- )
    #! Jump table entries are absolute addresses.
    ( dup postpone-word )
    compiled-offset 0 compile-cell 0 defer-xt ;

: check-jump-table ( vtable -- )
    length num-types = [
        "Jump table must have " num-types " entries" cat3 throw
    ] unless ;

: compile-jump-table ( vtable -- )
    #! Compile a table of words as a word-array of XTs.
    begin-jump-table
    dup check-jump-table
    [ jump-table-entry ] each ;

: TYPE ( -- )
    #! Peek datastack, store type # in EAX.
    ESI PUSH-[R]
    "type_of" SELF-CALL
    4 ESP R+I ;

: compile-generic ( vtable -- )
    #! Compile a faster alternative to
    #! : generic ( obj vtable -- )
    #!     >r dup type r> vector-nth execute ;
    TYPE  compile-jump-table ;

#generic [ compile-generic ] "generator" set-word-property

: ARITHMETIC-TYPE ( -- )
    #! Peek top two on datastack, store arithmetic type # in EAX.
    ESI EAX R>R
    EAX PUSH-[R]
    4 EAX R-I
    EAX PUSH-[R]
    "arithmetic_type" SELF-CALL
    8 ESP R+I ;

: compile-2generic ( vtable -- )
    #! Compile a faster alternative to
    #! : 2generic ( obj vtable -- )
    #!     >r 2dup arithmetic-type r> vector-nth execute ;
    ARITHMETIC-TYPE  compile-jump-table ;

#2generic [ compile-2generic ] "generator" set-word-property
