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
USE: math
USE: namespaces
USE: stack

: word-property ( word pname -- pvalue )
    swap word-plist assoc ;

: set-word-property ( word pvalue pname -- )
    pick word-plist
    pick [ set-assoc ] [ remove-assoc nip ] ifte
    swap set-word-plist ;

: ?word-primitive ( obj -- prim/0 )
    dup word? [ word-primitive ] [ drop 0 ] ifte ;

: defined?   ( obj -- ? ) ?word-primitive 0 = not ;
: compound?  ( obj -- ? ) ?word-primitive 1 = ;
: primitive? ( obj -- ? ) ?word-primitive 2 > ;
: symbol?    ( obj -- ? ) ?word-primitive 2 = ;

: comment?
    #! Comments are not first-class objects in CFactor.
    drop f ;

: word ( -- word ) global [ "last-word" get ] bind ;
: set-word ( word -- ) global [ "last-word" set ] bind ;

: define-compound ( word def -- )
    over set-word-parameter
    ( dup f "parsing" set-word-property )
    1 swap set-word-primitive ;

: define-symbol ( word -- )
    dup dup set-word-parameter
    2 swap set-word-primitive ;

: stack-effect ( word -- str ) "stack-effect" word-property ;
: documentation ( word -- str ) "documentation" word-property ;
