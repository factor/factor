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
USE: kernel-internals
USE: lists
USE: namespaces
USE: parser
USE: strings
USE: words
USE: vectors
USE: math
USE: math-internals

! A simple single-dispatch generic word system.

! "if I say I'd rather eat cheese than shit... doesn't mean
! those are the only two things I can eat." - Tac

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
! properties: "define-method" "builtin-types" "priority"

! Metaclasses have priority -- this induces an order in which
! methods are added to the vtable.

: undefined-method
    "No applicable method." throw ;

: metaclass ( class -- metaclass )
    "metaclass" word-property ;

: builtin-supertypes ( class -- list )
    #! A list of builtin supertypes of the class.
    dup metaclass "builtin-supertypes" word-property call ;

: set-vtable ( definition class vtable -- )
    >r "builtin-type" word-property r> set-vector-nth ;

: class-ord ( class -- n ) metaclass "priority" word-property ;

: class< ( cls1 cls2 -- ? )
    over metaclass over metaclass = [
        dup metaclass "class<" word-property call
    ] [
        swap class-ord swap class-ord <
    ] ifte ;

: methods ( generic -- alist )
    "methods" word-property hash>alist [ 2car class< ] sort ;

: add-method ( generic vtable definition class -- )
    #! Add the method entry to the vtable. Unlike define-method,
    #! this is called at vtable build time, and in the sorted
    #! order.
    dup metaclass "add-method" word-property
    [ [ undefined-method ] ] unless* call ;

: <empty-vtable> ( -- vtable )
    num-types [ drop [ undefined-method ] ] vector-project ;

: <vtable> ( generic -- vtable )
    <empty-vtable> over methods [
        ( generic vtable method )
        >r 2dup r> unswons add-method
    ] each nip ;

: define-generic ( word vtable -- )
    over "combination" word-property cons define-compound ;

: (define-method) ( definition class generic -- )
    [ "methods" word-property set-hash ] keep dup <vtable>
    define-generic ;

: init-methods ( word -- )
     dup "methods" word-property [
         drop
     ] [
        <namespace> "methods" set-word-property
     ] ifte ;

! Defining generic words
: (GENERIC) ( combination definer -- )
    #! Takes a combination parameter. A combination is a
    #! quotation that takes some objects and a vtable from the
    #! stack, and calls the appropriate row of the vtable.
    CREATE
    [ swap "definer" set-word-property ] keep
    [ swap "combination" set-word-property ] keep
    dup init-methods
    dup <vtable> define-generic ;

: single-combination ( obj vtable -- )
    >r dup type r> dispatch ; inline

: GENERIC:
    #! GENERIC: bar creates a generic word bar. Add methods to
    #! the generic word using M:.
    [ single-combination ] \ GENERIC: (GENERIC) ; parsing

: arithmetic-combination ( n n vtable -- )
    #! Note that the numbers remain on the stack, possibly after
    #! being coerced to a maximal type.
    >r arithmetic-type r> dispatch ; inline

: 2GENERIC:
    #! 2GENERIC: bar creates a generic word bar. Add methods to
    #! the generic word using M:. 2GENERIC words dispatch on
    #! arithmetic types and should not be used for non-numerical
    #! types.
    [ arithmetic-combination ] \ 2GENERIC: (GENERIC) ; parsing

: define-method ( class -- quotation )
    #! In a vain attempt at something resembling a "meta object
    #! protocol", we call the "define-method" word property with
    #! stack ( class generic definition -- ).
    metaclass "define-method" word-property
    [ [ -rot (define-method) ] ] unless* ;

: M: ( -- class generic [ ] )
    #! M: foo bar begins a definition of the bar generic word
    #! specialized to the foo type.
    scan-word  dup define-method  scan-word swap [ ] ; parsing

! Maps lists of builtin type numbers to class objects.
SYMBOL: classes

SYMBOL: object

: type-union ( list list -- list )
    append prune [ > ] sort ;

: type-intersection ( list list -- list )
    intersection [ > ] sort ;

: lookup-union ( typelist -- class )
    classes get hash [ object ] unless* ;

: class-or ( class class -- class )
    #! Return a class that both classes are subclasses of.
    swap builtin-supertypes
    swap builtin-supertypes
    type-union lookup-union ;

: class-and ( class class -- class )
    #! Return a class that is a subclass of both, or raise an
    #! error if this is impossible.
    over builtin-supertypes
    over builtin-supertypes
    type-intersection dup [
        nip nip lookup-union
    ] [
        drop [
            word-name , " and " , word-name ,
            " do not intersect" ,
        ] make-string throw
    ] ifte ;

: define-class ( class metaclass -- )
    dupd "metaclass" set-word-property
    dup builtin-supertypes [ > ] sort
    classes get set-hash ;

global [ classes get [ <namespace> classes set ] unless ] bind
