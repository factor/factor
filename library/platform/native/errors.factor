!:folding=indent:collapseFolds=1:

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
USE: continuations
USE: inspector
USE: lists
USE: stack
USE: stdio
USE: strings
USE: unparser

! This is a very lightweight exception handling system.

! catch stack
! error? --> top of catch stack, save error continuation,
! restore the continuation there
! restore continuation of 'catch' so that the catch is not in
! scope -- it can throw up.
! if top level catches error, it prints a message.
!
! The kernel throws errors as lists. The first element is an
! integer.

: kernel-error? ( obj -- ? )
    dup cons? [ car fixnum? ] [ drop f ] ifte ;

: ?nth ( n list -- obj )
    dup >r length min 0 max r> nth ;

: error# ( n -- str )
    [
        "Handle expired"
        "Undefined word"
        "Type check"
        "Array range check"
        "Underflow"
    ] ?nth ;

: kernel-error% ( error -- )
    car error# % ": " % unparse % ;

: error>str  ( error -- str )
    dup kernel-error? [
        <% kernel-error% %>
    ] [
        unparse
    ] ifte ;
    
: default-error-handler ( error -- )
    #! Print the error and return to the top level.
    "Uncaught exception." print
    "-------------------" print
    "Datastack:" print
    .s
    "Callstack:" print
    .r
    "Namestack:" print
    .n
    terpri
    "ERROR: " write error>str print
    suspend ;

: throw ( error -- )
    #! Throw an error. If no catch handlers are installed, the
    #! default-error-handler is called.
    default-error-handler ;
