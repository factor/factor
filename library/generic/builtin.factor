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

! Builtin metaclass for builtin types: fixnum, word, cons, etc.
SYMBOL: builtin

builtin [
    "builtin-type" word-property unit
] "builtin-supertypes" set-word-property

builtin [
    ( vtable definition class -- )
    rot set-vtable
] "add-method" set-word-property

builtin 50 "priority" set-word-property

: builtin-predicate ( type# symbol -- word )
    predicate-word [
        swap [ swap type eq? ] cons define-compound
    ] keep ;

: builtin-class ( number type -- )
    dup undefined? [ dup define-symbol ] when
    2dup builtin-predicate
    dupd "predicate" set-word-property
    dup builtin "metaclass" set-word-property
    swap "builtin-type" set-word-property ;

: BUILTIN:
    #! Followed by type name and type number. Define a built-in
    #! type predicate with this number.
    CREATE scan-word swap builtin-class ; parsing

: builtin-type ( symbol -- n )
    "builtin-type" word-property ;
