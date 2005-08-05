! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors hashtables kernel kernel-internals lists
namespaces parser sequences strings words vectors math
math-internals ;

! A simple single-dispatch generic word system.

: predicate-word ( word -- word )
    word-name "?" append create-in ;

: define-predicate ( class predicate quot -- )
    dupd define-compound
    2dup unit "predicate" set-word-prop
    swap "predicating" set-word-prop ;

DEFER: delegate

! Metaclasses have priority -- this induces an order in which
! methods are added to the vtable.

: metaclass ( class -- metaclass )
    "metaclass" word-prop ;

: builtin-supertypes ( class -- list )
    #! A list of builtin supertypes of the class.
    dup metaclass "builtin-supertypes" word-prop call ;

: set-vtable ( definition class vtable -- )
    >r "builtin-type" word-prop r> set-nth ;

: 2types ( class class -- seq seq )
    swap builtin-supertypes swap builtin-supertypes ;

: (class<) ( class class -- ? )
    2types contained? ;

: class-ord ( class -- n ) metaclass "priority" word-prop ;

: metaclass= ( class class -- ? )
    swap metaclass swap metaclass = ;

: class< ( cls1 cls2 -- ? )
    #! Test if class1 is a subclass of class2.
    over class-ord over class-ord - dup 0 = [
        drop dup metaclass "class<" word-prop call
    ] [
        0 < 2nip
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

: picker% "picker" word-prop % ;

: dispatcher% "dispatcher" word-prop % ;

: error-method ( generic -- method )
    [ dup picker% literalize , \ no-method , ] make-list ;

: empty-method ( generic -- method )
    dup "picker" word-prop [ dup ] = [
        [
            [ dup delegate ] %
            [ dup , ] make-list ,
            error-method ,
            \ ?ifte ,
        ] make-list
    ] [
        error-method
    ] ifte ;

: <empty-vtable> ( generic -- vtable )
    empty-method num-types swap <repeated> >vector ;

: <vtable> ( generic -- vtable )
    dup <empty-vtable> over methods [
        ( generic vtable method )
        >r 2dup r> unswons add-method
    ] each nip ;

: (small-generic) ( word methods -- quot )
    [
        2dup cdr (small-generic) [
            >r >r picker%
            r> car unswons "predicate" word-prop %
            , r> , \ ifte ,
        ] make-list
    ] [
        empty-method
    ] ifte* ;

: small-generic ( word -- def )
    dup methods reverse (small-generic) ;

: big-generic ( word -- def )
    [
        dup picker%
        dup dispatcher%
        <vtable> ,
        \ dispatch ,
    ] make-list ;

: small-generic? ( word -- ? )
    dup "methods" word-prop hash-size 3 <=
    swap "dispatcher" word-prop [ type ] = and ;

: make-generic ( word -- )
    dup dup small-generic? [
        small-generic
    ] [
        big-generic
    ] ifte  (define-compound) ;

: define-method ( class generic definition -- )
    -rot
    over metaclass word? [
        over word-name " is not a class" append throw
    ] unless
    [ "methods" word-prop set-hash ] keep make-generic ;

: forget-method ( class generic -- )
    [ "methods" word-prop remove-hash ] keep make-generic ;

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
    "dispatcher" word-prop ;

M: generic definer drop \ G: ;

PREDICATE: generic simple-generic ( word -- ? )
    "picker" word-prop [ dup ] = ;

PREDICATE: generic 2generic ( word -- ? )
    "dispatcher" word-prop [ arithmetic-type ] = ;

! Maps lists of builtin type numbers to class objects.
SYMBOL: typemap

SYMBOL: object

: lookup-union ( typelist -- class )
    [ > ] sort typemap get hash [ object ] unless* ;

: class-or ( class class -- class )
    #! Return a class that both classes are subclasses of.
    2dup class< [
        nip
    ] [
        2dup swap class< [
            drop
        ] [
            2types seq-union lookup-union
        ] ifte
    ] ifte ;

: class-and ( class class -- class )
    #! Return a class that is a subclass of both, or null in
    #! the degenerate case.
    2dup class< [
        drop
    ] [
        2dup swap class< [
            nip 
        ] [
            2types seq-intersect lookup-union
        ] ifte
    ] ifte ;

: define-class ( class metaclass -- )
    dupd "metaclass" set-word-prop
    dup builtin-supertypes [ > ] sort
    typemap get set-hash ;

typemap get [ <namespace> typemap set ] unless
