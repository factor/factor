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

! Predicate metaclass for generalized predicate dispatch.
SYMBOL: predicate

: predicate-dispatch ( existing definition class -- dispatch )
    [
        \ dup , "predicate" word-property , , , \ ifte ,
    ] make-list ;

: predicate-method ( vtable definition class type# -- )
    >r rot r> swap [
        vector-nth
        ( vtable definition class existing )
        -rot predicate-dispatch
    ] 2keep set-vector-nth ;

predicate [
    "superclass" word-property builtin-supertypes
] "builtin-supertypes" set-word-property

predicate [
    ( vtable definition class -- )
    dup builtin-supertypes [
        ( vtable definition class type# )
        >r 3dup r> predicate-method
    ] each 3drop
] "add-method" set-word-property

predicate 25 "priority" set-word-property

: define-predicate ( class predicate definition -- )
    rot "superclass" word-property "predicate" word-property
    [ \ dup , , , [ drop f ] , \ ifte , ] make-list
    define-compound ;

: PREDICATE: ( -- class predicate definition )
    #! Followed by a superclass name, then a class name.
    scan-word
    CREATE
    dup rot "superclass" set-word-property
    dup predicate "metaclass" set-word-property
    dup predicate-word
    [ dupd "predicate" set-word-property ] keep
    [ define-predicate ] [ ] ; parsing
