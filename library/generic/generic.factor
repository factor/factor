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

! A simple single-dispatch generic word system.

: predicate-word ( word -- word )
    word-name "?" cat2 "in" get create ;

! Terminology:
! - type: a datatype built in to the runtime, eg fixnum, word
! cons. All objects have exactly one type, new types cannot be
! defined, and types are disjoint.
! - class: a user defined way of differentiating objects, either
! based on type, or some combination of type, predicate, or
! method map.
! - traits: a hashtable has traits of its traits slot is set to
! a hashtable mapping selector names to method definitions.
! The class of an object with traits is determined by the object
! identity of the traits method map.
! - metaclass: a metaclass is a symbol with a handful of word
! properties: "define-method" "builtin-types"

: undefined-method
    "No applicable method." throw ;

: metaclass ( class -- metaclass )
    "metaclass" word-property ;

: builtin-supertypes ( class -- list )
    #! A list of builtin supertypes of the class.
    dup metaclass "builtin-supertypes" word-property call ;

: add-method ( definition type vtable -- )
    >r "builtin-type" word-property r> set-vector-nth ;

: define-generic ( word vtable -- )
    2dup "vtable" set-word-property
    [ generic ] cons define-compound ;

: <vtable> ( default -- vtable )
    num-types [ drop dup ] vector-project nip ;

DEFER: add-traits-dispatch

! Defining generic words
: GENERIC:
    #! GENERIC: bar creates a generic word bar that calls the
    #! bar method on the traits object, with the traits object
    #! on the stack.
    CREATE [ undefined-method ] <vtable>
    2dup add-traits-dispatch
    define-generic ; parsing

: define-method ( class -- quotation )
    #! In a vain attempt at something resembling a "meta object
    #! protocol", we call the "define-method" word property with
    #! stack ( class generic definition -- ).
    metaclass "define-method" word-property
    [ [ undefined-method ] ] unless* ;

: M: ( -- class generic [ ] )
    #! M: foo bar begins a definition of the bar generic word
    #! specialized to the foo type.
    scan-word  dup define-method  scan-word swap [ ] ; parsing
