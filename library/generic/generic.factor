! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors hashtables kernel kernel-internals lists
namespaces parser sequences strings words vectors math
math-internals ;

! A simple single-dispatch generic word system.

: predicate-word ( word -- word ) word-name "?" cat2 create-in ;

! Terminology:
! - type: a datatype built in to the runtime, eg fixnum, word
! cons. All objects have exactly one type, new types cannot be
! defined, and types are disjoint.
! - class: a user defined way of differentiating objects, either
! based on type, or some combination of type, predicate, or
! method map.
! - metaclass: a metaclass is a symbol with a handful of word
! properties: "builtin-supertypes" "priority" "add-method"
! "class<"

! Metaclasses have priority -- this induces an order in which
! methods are added to the vtable.

: metaclass ( class -- metaclass )
    "metaclass" word-prop ;

: builtin-supertypes ( class -- list )
    #! A list of builtin supertypes of the class.
    dup metaclass "builtin-supertypes" word-prop call ;

: set-vtable ( definition class vtable -- )
    >r "builtin-type" word-prop r> set-nth ;

: class-ord ( class -- n ) metaclass "priority" word-prop ;

: class< ( cls1 cls2 -- ? )
    #! Test if class1 is a subclass of class2.
    over metaclass over metaclass = [
        dup metaclass "class<" word-prop call
    ] [
        swap class-ord swap class-ord <
    ] ifte ;

: methods ( generic -- alist )
    "methods" word-prop hash>alist [ 2car class< ] sort ;

: order ( generic -- list )
    "methods" word-prop hash-keys [ class< ] sort ;

: add-method ( generic vtable definition class -- )
    #! Add the method entry to the vtable. Unlike define-method,
    #! this is called at vtable build time, and in the sorted
    #! order.
    dup metaclass "add-method" word-prop [
        [ "Metaclass is missing add-method" throw ]
    ] unless* call ;

: <empty-vtable> ( generic -- vtable )
    [ literal, \ no-method , ] make-list
    num-types swap <repeated> >vector ;

: <vtable> ( generic -- vtable )
    dup <empty-vtable> over methods [
        ( generic vtable method )
        >r 2dup r> unswons add-method
    ] each nip ;

: make-generic ( word -- )
    #! (define-compound) is used to avoid resetting generic
    #! word properties.
    [
        dup "picker" word-prop %
        dup "dispatcher" word-prop %
        dup <vtable> ,
        \ dispatch ,
    ] make-list (define-compound) ;

: define-method ( class generic definition -- )
    -rot
    over metaclass word? [
        over word-name " is not a class" append throw
    ] unless
    [ "methods" word-prop set-hash ] keep make-generic ;

: init-methods ( word -- )
     dup "methods" word-prop [
         drop
     ] [
        <namespace> "methods" set-word-prop
     ] ifte ;

! Defining generic words
: define-generic* ( picker dispatcher word -- )
    [ swap "dispatcher" set-word-prop ] keep
    [ swap "picker" set-word-prop ] keep
    dup init-methods make-generic ;

: define-generic ( word -- )
    >r [ dup ] [ type ] r> define-generic* ;

PREDICATE: compound generic ( word -- ? )
    dup "dispatcher" word-prop [ type ] =
    swap "picker" word-prop [ dup ] = and ;
M: generic definer drop \ GENERIC: ;

: define-2generic ( word -- )
    >r [ ] [ arithmetic-type ] r> define-generic* ;

PREDICATE: compound 2generic ( word -- ? )
    dup "dispatcher" word-prop [ arithmetic-type ] =
    swap "picker" word-prop not and ;
M: 2generic definer drop \ 2GENERIC: ;

! Maps lists of builtin type numbers to class objects.
SYMBOL: typemap

SYMBOL: object

: type-union ( list list -- list )
    append prune ;

: lookup-union ( typelist -- class )
    [ > ] sort typemap get hash [ object ] unless* ;

: class-or ( class class -- class )
    #! Return a class that both classes are subclasses of.
    swap builtin-supertypes
    swap builtin-supertypes
    type-union lookup-union ;

: class-or-list ( list -- class )
    #! Return a class that every class in the list is a
    #! subclass of.
    [
        [ builtin-supertypes [ unique, ] each ] each
    ] make-list lookup-union ;

: class-and ( class class -- class )
    #! Return a class that is a subclass of both, or null in
    #! the degenerate case.
    swap builtin-supertypes swap builtin-supertypes
    intersection lookup-union ;

: define-class ( class metaclass -- )
    dupd "metaclass" set-word-prop
    dup builtin-supertypes [ > ] sort
    typemap get set-hash ;

typemap get [ <namespace> typemap set ] unless
