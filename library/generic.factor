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

! Catch-all metaclass for providing a default method.
SYMBOL: object

: define-generic ( word vtable -- )
    2dup "vtable" set-word-property
    [ generic ] cons define-compound ;

: <vtable> ( default -- vtable )
    num-types [ drop dup ] vector-project nip ;

: define-object ( generic definition -- )
    <vtable> define-generic drop ;

object [ define-object ] "define-method" set-word-property

: predicate-word ( word -- word )
    word-name "?" cat2 "in" get create ;

: builtin-predicate ( type# symbol -- )
    predicate-word swap [ swap type eq? ] cons define-compound ;

: add-method ( definition type vtable -- )
    >r "builtin-type" word-property r> set-vector-nth ;

: define-builtin ( type generic definition -- )
    -rot "vtable" word-property add-method ;

: builtin-class ( number type -- )
    dup undefined? [ dup define-symbol ] when
    2dup builtin-predicate
    dup [ define-builtin ] "define-method" set-word-property
    swap "builtin-type" set-word-property ;

: BUILTIN:
    #! Followed by type name and type number. Define a built-in
    #! type predicate with this number.
    CREATE scan-word swap builtin-class ; parsing

: builtin-type ( symbol -- n )
    "builtin-type" word-property ;

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

: undefined-method
    "No applicable method." throw ;

: traits-method ( selector traits -- traits quot )
    #! Look up the method with the traits object on the stack.
    #! Returns the traits to call the method on; either the
    #! original object, or one of the delegates.
    2dup object-map hash* dup [
        rot drop cdr ( method is defined )
    ] [
        drop delegate swap hash* dup [
            cdr traits-method ( check delegate )
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

: define-traits ( type generic definition -- )
    swap rot traits-map set-hash ;

: TRAITS:
    #! TRAITS: foo creates a new traits type. Instances can be
    #! created with <foo>, and tested with foo?.
    CREATE
    dup define-symbol
    dup init-traits-map
    dup [ define-traits ] "define-method" set-word-property
    traits-predicate ; parsing

: add-traits-dispatch ( word vtable -- )
    >r unit [ car swap traits-method call ] cons \ vector r>
    add-method ;

: GENERIC:
    #! GENERIC: bar creates a generic word bar that calls the
    #! bar method on the traits object, with the traits object
    #! on the stack.
    CREATE [ undefined-method ] <vtable>
    2dup add-traits-dispatch
    define-generic ; parsing

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

: define-method ( type -- quotation )
    #! In a vain attempt at something resembling a "meta object
    #! protocol", we call the "define-method" word property with
    #! stack ( type generic definition -- ).
    "define-method" word-property
    [ [ undefined-method ] ] unless* ;

: M: ( -- type generic [ ] )
    #! M: foo bar begins a definition of the bar generic word
    #! specialized to the foo type.
    scan-word  dup define-method  scan-word swap [ ] ; parsing
