! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors hashtables kernel kernel-internals lists
namespaces parser strings words vectors math math-internals ;

! A simple single-dispatch generic word system.

: predicate-word ( word -- word )
    word-name "?" cat2 create-in ;

! Terminology:
! - type: a datatype built in to the runtime, eg fixnum, word
! cons. All objects have exactly one type, new types cannot be
! defined, and types are disjoint.
! - class: a user defined way of differentiating objects, either
! based on type, or some combination of type, predicate, or
! method map.
! - metaclass: a metaclass is a symbol with a handful of word
! properties: "builtin-types" "priority"

! Metaclasses have priority -- this induces an order in which
! methods are added to the vtable.

: metaclass ( class -- metaclass )
    "metaclass" word-property ;

: builtin-supertypes ( class -- list )
    #! A list of builtin supertypes of the class.
    dup metaclass "builtin-supertypes" word-property call ;

: set-vtable ( definition class vtable -- )
    >r "builtin-type" word-property r> set-vector-nth ;

: class-ord ( class -- n ) metaclass "priority" word-property ;

: class< ( cls1 cls2 -- ? )
    #! Test if class1 is a subclass of class2.
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
    dup metaclass "add-method" word-property [
        [ "Metaclass is missing add-method" throw ]
    ] unless* call ;

: <empty-vtable> ( generic -- vtable )
    unit num-types
    [ drop dup [ car undefined-method ] cons ] vector-project
    nip ;

: <vtable> ( generic -- vtable )
    dup <empty-vtable> over methods [
        ( generic vtable method )
        >r 2dup r> unswons add-method
    ] each nip ;

: make-generic ( word vtable -- )
    over "combination" word-property cons define-compound ;

: define-method ( class generic definition -- )
    -rot
    [ "methods" word-property set-hash ] keep dup <vtable>
    make-generic ;

: init-methods ( word -- )
     dup "methods" word-property [
         drop
     ] [
        <namespace> "methods" set-word-property
     ] ifte ;

! Defining generic words
: define-generic ( combination definer word -- )
    #! Takes a combination parameter. A combination is a
    #! quotation that takes some objects and a vtable from the
    #! stack, and calls the appropriate row of the vtable.
    [ swap "definer" set-word-property ] keep
    [ swap "combination" set-word-property ] keep
    dup init-methods
    dup <vtable> make-generic ;

: single-combination ( obj vtable -- )
    >r dup type r> dispatch ; inline

PREDICATE: compound generic ( word -- ? )
    "combination" word-property [ single-combination ] = ;

: arithmetic-combination ( n n vtable -- )
    #! Note that the numbers remain on the stack, possibly after
    #! being coerced to a maximal type.
    >r arithmetic-type r> dispatch ; inline

PREDICATE: compound 2generic ( word -- ? )
    "combination" word-property [ arithmetic-combination ] = ;

! Maps lists of builtin type numbers to class objects.
SYMBOL: classes

SYMBOL: object

: type-union ( list list -- list )
    append prune ;

: lookup-union ( typelist -- class )
    [ > ] sort classes get hash [ object ] unless* ;

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
    #! Return a class that is a subclass of both, or raise an
    #! error if this is impossible.
    swap builtin-supertypes swap builtin-supertypes
    intersection lookup-union ;

: define-class ( class metaclass -- )
    dupd "metaclass" set-word-property
    dup builtin-supertypes [ > ] sort
    classes get set-hash ;

classes get [ <namespace> classes set ] unless
