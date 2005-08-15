! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors hashtables kernel kernel-internals lists
namespaces parser sequences strings words vectors math
math-internals ;

! A simple single-dispatch generic word system.

! Maps lists of builtin type numbers to class objects.
SYMBOL: typemap
SYMBOL: object
SYMBOL: null

: predicate-word ( word -- word )
    word-name "?" append create-in ;

: define-predicate ( class predicate quot -- )
    dupd define-compound
    2dup unit "predicate" set-word-prop
    swap "predicating" set-word-prop ;

: metaclass ( class -- metaclass )
    "metaclass" word-prop ;

: types ( class -- types )
    dup "types" word-prop [ ] [
        "superclass" word-prop [ types ] [ [ ] ] ifte*
    ] ?ifte ;

: 2types ( class class -- seq seq ) swap types swap types ;

: custom-class< metaclass "class<" word-prop ;

: class< ( cls1 cls2 -- ? )
    #! Test if class1 is a subclass of class2.
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ dup custom-class< ] [ dup custom-class< call ] }
        { [ t ] [ 2types contained? ] }
    } cond ;

: class-compare ( cls1 cls2 -- -1/0/1 )
    2dup eq? [ 2drop 0 ] [ class< 1 -1 ? ] ifte ;

: methods ( generic -- alist )
    "methods" word-prop hash>alist [ 2car class-compare ] sort ;

: order ( generic -- list )
    "methods" word-prop hash-keys [ class-compare ] sort ;

: make-generic ( word -- )
    dup dup "combination" word-prop call (define-compound) ;

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
: define-generic* ( picker combination word -- )
    [ swap "combination" set-word-prop ] keep
    [ swap "picker" set-word-prop ] keep
    dup init-methods make-generic ;

PREDICATE: compound generic ( word -- ? )
    "combination" word-prop ;

M: generic definer drop \ G: ;

PREDICATE: generic simple-generic ( word -- ? )
    "picker" word-prop [ dup ] = ;

: lookup-union ( typelist -- class )
    [ - ] sort typemap get hash [ object ] unless* ;

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

: min-class ( class seq -- class/f )
    #! Is this class the smallest class in the sequence?
    [ dupd class-and null = not ] subset
    [ class-compare neg ] sort
    tuck [ class< ] all-with? [ first ] [ drop f ] ifte ;

: define-class ( class metaclass -- )
    dupd "metaclass" set-word-prop
    dup types [ - ] sort typemap get set-hash ;

typemap get [ <namespace> typemap set ] unless
