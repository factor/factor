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

USE: combinators
USE: errors
USE: hashtables
USE: kernel
USE: lists
USE: namespaces
USE: parser
USE: stack
USE: strings
USE: words
USE: vectors

! A simple prototype-based generic word system.

! Hashtable slot holding a selector->method map.
SYMBOL: traits

! Hashtable slot holding an optional delegate. Any undefined
! methods are called on the delegate. The object can also
! manually pass any methods on to the delegate.
SYMBOL: delegate

: traits-map ( type -- hash )
    #! The method map word property maps selector words to
    #! definitions.
    "traits-map" word-property ;

: object-map ( obj -- hash )
    #! Get the method map for an object.
    #! We will use hashtable? here when its a first-class type.
    dup vector? [ traits swap hash ] [ drop f ] ifte ;

: init-traits-map ( word -- )
    <namespace> "traits-map" set-word-property ;

: no-method
    "No applicable method." throw ;

: method ( selector traits -- quot )
    #! Look up the method with the traits object on the stack.
    2dup object-map hash* dup [
        nip nip cdr ( method is defined )
    ] [
        drop delegate swap hash* dup [
            cdr method ( check delegate )
        ] [
            3drop [ no-method ] ( no delegate )
        ] ifte
    ] ifte ;

: predicate-word ( word -- word )
    word-name "?" cat2 "in" get create ;

: define-predicate ( word -- )
    #! foo? where foo is a traits type tests if the top of stack
    #! is of this type.
    dup predicate-word swap
    [ object-map ] swap traits-map [ eq? ] cons append
    define-compound ;

: TRAITS:
    #! TRAITS: foo creates a new traits type. Instances can be
    #! created with <foo>, and tested with foo?.
    CREATE
    dup define-symbol
    dup init-traits-map
    define-predicate ; parsing

: GENERIC:
    #! GENERIC: bar creates a generic word bar that calls the
    #! bar method on the traits object, with the traits object
    #! on the stack.
    CREATE
    dup unit [ car over method call ] cons
    define-compound ; parsing

: constructor-word ( word -- word )
    word-name "<" swap ">" cat3 "in" get create ;

: define-constructor ( word -- )
    [ constructor-word [ <namespace> ] ] keep
    traits-map [ traits pick set-hash ] cons append
    define-compound ;

: C: ( -- word [ ] )
    #! C: foo ... begins definition for <foo> where foo is a
    #! traits type. We have to reverse the list at the end,
    #! since the parser conses onto the list, and it will be
    #! reversed again by ;C.
    scan-word [ constructor-word [ <namespace> ] ] keep
    traits-map [ traits pick set-hash ] cons append reverse ;
    parsing

: ;C ( word [ ] -- )
    POSTPONE: ; ; parsing

: M: ( -- type generic [ ] )
    #! M: foo bar begins a definition of the bar generic word
    #! specialized to the foo type.
    scan-word scan-word f ; parsing

: ;M ( type generic def -- )
    #! ;M ends a method definition.
    rot traits-map [ reverse put ] bind ; parsing
