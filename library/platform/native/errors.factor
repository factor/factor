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

IN: errors
USE: arithmetic
USE: combinators
USE: continuations
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: prettyprint
USE: stack
USE: stdio
USE: strings
USE: unparser
USE: vectors

! This is a very lightweight exception handling system.

: catchstack* ( -- cs ) 6 getenv ;
: catchstack ( -- cs ) catchstack* clone ;
: set-catchstack* ( cs -- ) 6 setenv ;
: set-catchstack ( cs -- ) clone set-catchstack* ;

: kernel-error? ( obj -- ? )
    dup cons? [ car fixnum? ] [ drop f ] ifte ;

: ?nth ( n list -- obj )
    over [ dup >r length min 0 max r> nth ] [ 2drop f ] ifte ;

: error# ( n -- str )
    [
        "Expired handle: "
        "Undefined word: "
        "Type check: "
        "Array range check: "
        "Underflow"
        "Bad primitive: "
        "Incompatible handle: "
        "I/O error: "
    ] ?nth ;

: ?kernel-error ( cons -- error# param )
    dup cons? [ uncons dup cons? [ car ] when ] [ f ] ifte ;

: kernel-error. ( error -- )
    ?kernel-error swap error# dup "" ? write
    dup [ . ] [ drop terpri ] ifte ;

: error. ( error -- str )
    dup kernel-error? [ kernel-error. ] [ . ] ifte ;

DEFER: >c
DEFER: throw
DEFER: default-error-handler

: init-errors ( -- )
    64 <vector> set-catchstack*
    [ 1 exit* ] >c ( last resort )
    [ default-error-handler 1 exit* ] >c
    [ throw ] 5 setenv ( kernel calls on error ) ;
