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
USE: math

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

: metaclass ( class -- metaclass )
    "metaclass" word-property ;

: builtin-supertypes ( class -- list )
    #! A list of builtin supertypes of the class.
    dup metaclass "builtin-supertypes" word-property call ;

! Catch-all metaclass for providing a default method.
SYMBOL: object

: define-generic ( word vtable -- )
    2dup "vtable" set-word-property
    [ generic ] cons define-compound ;

: <vtable> ( default -- vtable )
    num-types [ drop dup ] vector-project nip ;

: define-object ( generic definition -- )
    <vtable> define-generic drop ;

object object "metaclass" set-word-property

object [
    define-object
] "define-method" set-word-property

object [
    drop num-types count
] "builtin-supertypes" set-word-property

! Builtin metaclass for builtin types: fixnum, word, cons, etc.
SYMBOL: builtin

: add-method ( definition type vtable -- )
    >r "builtin-type" word-property r> set-vector-nth ;

: builtin-method ( type generic definition -- )
    -rot "vtable" word-property add-method ;

builtin [ builtin-method ] "define-method" set-word-property

builtin [
    "builtin-type" word-property unit
] "builtin-supertypes" set-word-property

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

! Predicate metaclass for generalized predicate dispatch.
SYMBOL: predicate

: predicate-dispatch ( class definition existing -- dispatch )
    [
        \ dup ,
        rot "predicate" word-property ,
        swap , , \ ifte ,
    ] make-list ;

: (predicate-method) ( class generic definition type# -- )
    rot "vtable" word-property
    [ vector-nth predicate-dispatch ] 2keep
    set-vector-nth ;

: predicate-method ( class generic definition -- )
    pick builtin-supertypes [
        >r 3dup r> (predicate-method)
    ] each 3drop ;

predicate [
    predicate-method
] "define-method" set-word-property

predicate [
    "superclass" word-property builtin-supertypes
] "builtin-supertypes" set-word-property

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

! Traits metaclass for user-defined classes based on hashtables

! Hashtable slot holding a selector->method map.
SYMBOL: traits

: traits-map ( class -- hash )
    #! The method map word property maps selector words to
    #! definitions.
    "traits-map" word-property ;

: traits-method ( class generic definition -- )
    swap rot traits-map set-hash ;

traits [ traits-method ] "define-method" set-word-property

traits [
    \ vector "builtin-type" word-property unique,
] "builtin-supertypes" set-word-property

! Hashtable slot holding an optional delegate. Any undefined
! methods are called on the delegate. The object can also
! manually pass any methods on to the delegate.
SYMBOL: delegate

: object-map ( obj -- hash )
    #! Get the method map for an object.
    #! We will use hashtable? here when its a first-class type.
    dup vector? [ traits swap hash ] [ drop f ] ifte ;

: init-traits-map ( word -- )
    <namespace> "traits-map" set-word-property ;

: undefined-method
    "No applicable method." throw ;

: traits-dispatch ( selector traits -- traits quot )
    #! Look up the method with the traits object on the stack.
    #! Returns the traits to call the method on; either the
    #! original object, or one of the delegates.
    2dup object-map hash* dup [
        rot drop cdr ( method is defined )
    ] [
        drop delegate swap hash* dup [
            cdr traits-dispatch ( check delegate )
        ] [
            drop [ undefined-method ] ( no delegate )
        ] ifte
    ] ifte ;

: traits-predicate ( word -- )
    #! foo? where foo is a traits type tests if the top of stack
    #! is of this type.
    dup predicate-word swap
    traits-map [ swap object-map eq? ] cons
    define-compound ;

: TRAITS:
    #! TRAITS: foo creates a new traits type. Instances can be
    #! created with <foo>, and tested with foo?.
    CREATE
    dup define-symbol
    dup init-traits-map
    dup traits "metaclass" set-word-property
    traits-predicate ; parsing

: add-traits-dispatch ( word vtable -- )
    >r unit [ car swap traits-dispatch call ] cons \ vector r>
    add-method ;

: constructor-word ( word -- word )
    word-name "<" swap ">" cat3 "in" get create ;

: define-constructor ( constructor traits definition -- )
    >r
    traits-map [ traits pick set-hash ] cons \ <namespace> swons
    r> append define-compound ;

: C: ( -- constructor traits [ ] )
    #! C: foo ... begins definition for <foo> where foo is a
    #! traits type.
    scan-word [ constructor-word ] keep
    [ define-constructor ] [ ] ; parsing

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
