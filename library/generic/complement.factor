! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2005 Slava Pestov.
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
USE: math

! Complement metaclass, contains all objects not in a certain class.
SYMBOL: complement

complement [
    "complement" word-property builtin-supertypes
    num-types count
    difference
] "builtin-supertypes" set-word-property

complement [
    ( generic vtable definition class -- )
    drop num-types [ >r 3dup r> add-method ] times* 3drop
] "add-method" set-word-property

complement 90 "priority" set-word-property

complement [
    swap "complement" word-property
    swap "complement" word-property
    class< not
] "class<" set-word-property

: complement-predicate ( complement -- list )
    "predicate" word-property [ not ] append ;

: define-complement ( class predicate complement -- )
    [ complement-predicate define-compound ] keep
    dupd "complement" set-word-property
    complement define-class ;

: COMPLEMENT: ( -- class predicate definition )
    #! Followed by a class name, then a complemented class.
    CREATE
    dup intern-symbol
    dup predicate-word
    [ dupd unit "predicate" set-word-property ] keep
    scan-word define-complement ; parsing
