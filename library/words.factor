! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003 Slava Pestov.
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
USE: generic
USE: hashtables
USE: kernel
USE: kernel-internals
USE: lists
USE: math
USE: namespaces
USE: strings

BUILTIN: word 1

M: word hashcode 1 integer-slot ;

: word-xt     ( w -- xt ) >word 2 integer-slot ; inline
: set-word-xt ( xt w -- ) >word 2 set-integer-slot ; inline

: word-primitive ( w -- n ) >word 3 integer-slot ; inline
: set-word-primitive ( n w -- )
    >word [ 3 set-integer-slot ] keep update-xt ; inline

: word-parameter     ( w -- obj ) >word 4 slot ; inline
: set-word-parameter ( obj w -- ) >word 4 set-slot ; inline

: word-plist     ( w -- obj ) >word 5 slot ; inline
: set-word-plist ( obj w -- ) >word 5 set-slot ; inline

: call-count     ( w -- n ) >word 6 integer-slot ; inline
: set-call-count ( n w -- ) >word 6 set-integer-slot ; inline

: allot-count     ( w -- n ) >word 7 integer-slot ; inline
: set-allot-count ( n w -- ) >word 7 set-integer-slot ; inline

SYMBOL: vocabularies

: word-property ( word pname -- pvalue )
    swap word-plist assoc ; inline

: set-word-property ( word pvalue pname -- )
    pick word-plist
    pick [ set-assoc ] [ remove-assoc nip ] ifte
    swap set-word-plist ; inline

PREDICATE: word compound  ( obj -- ? ) word-primitive 1 = ;
PREDICATE: word primitive ( obj -- ? ) word-primitive 2 > ;
PREDICATE: word symbol    ( obj -- ? ) word-primitive 2 = ;
PREDICATE: word undefined ( obj -- ? ) word-primitive 0 = ;

: define ( word primitive parameter -- )
    pick set-word-parameter
    over set-word-primitive
    f "parsing" set-word-property ;

: define-compound ( word def -- ) 1 swap define ;
: define-symbol   ( word -- ) 2 over define ;

: intern-symbol ( word -- )
    dup undefined? [ define-symbol ] [ drop ] ifte ;

: word-name       ( word -- str ) "name" word-property ;
: word-vocabulary ( word -- str ) "vocabulary" word-property ;
: stack-effect    ( word -- str ) "stack-effect" word-property ;
: documentation   ( word -- str ) "documentation" word-property ;
