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

IN: words
USE: combinators
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: stack

: word-property ( pname word -- pvalue )
    word-plist assoc ;

: set-word-property ( pvalue pname word -- )
    dup >r word-plist set-assoc r> set-word-plist ;

: defined? ( obj -- ? )
    dup word? [ word-primitive 0 = not ] [ drop f ] ifte ;

: compound? ( obj -- ? )
    dup word? [ word-primitive 1 = ] [ drop f ] ifte ;

: primitive? ( obj -- ? )
    dup word? [ word-primitive 1 = not ] [ drop f ] ifte ;

! Various features not supported by native Factor.
: comment? drop f ;

: word ( -- word )
    global [ "last-word" get ] bind ;

: set-word ( word -- )
    global [ "last-word" set ] bind ;

: define-compound ( word def -- )
    #! Define a compound word at runtime.
    over set-word-parameter
    1 swap set-word-primitive ;

: stack-effect ( word -- str )
    "stack-effect" swap word-property ;

: documentation ( word -- str )
    "documentation" swap word-property ;
