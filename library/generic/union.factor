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

IN: generic
USE: errors
USE: hashtables
USE: kernel
USE: lists
USE: namespaces
USE: parser
USE: strings
USE: words
USE: vectors

! Union metaclass for dispatch on multiple classes.
SYMBOL: union

union [
    [ ] swap "members" word-property [
        builtin-supertypes append
    ] each
] "builtin-supertypes" set-word-property

union [
    ( vtable definition class -- )
    "members" word-property [ >r 2dup r> add-method ] each 2drop
] "add-method" set-word-property

union 30 "priority" set-word-property

: union-predicate ( definition -- list )
    [
        [
            \ dup ,
            unswons "predicate" word-property ,
            [ drop t ] ,
            union-predicate ,
            \ ifte ,
        ] make-list
    ] [
        [ drop f ]
    ] ifte* ;

: define-union ( class predicate definition -- )
    [ union-predicate define-compound ] keep
    "members" set-word-property ;

: UNION: ( -- class predicate definition )
    #! Followed by a class name, then a list of union members.
    CREATE
    dup union "metaclass" set-word-property
    dup predicate-word
    [ dupd "predicate" set-word-property ] keep
    [ define-union ] [ ] ; parsing
