! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: lists USING: generic kernel kernel-internals ;

! This file contains vital list-related words that everything
! else depends on, and is loaded early in bootstrap.
! lists.factor has everything else.

BUILTIN: cons 2 [ 0 "car" f ] [ 1 "cdr" f ] ;

! We borrow an idiom from Common Lisp. The car/cdr of an empty
! list is the empty list.
M: f car ;
M: f cdr ;

: swons ( cdr car -- [[ car cdr ]] )
    #! Push a new cons cell. If the cdr is f or a proper list,
    #! has the effect of prepending the car to the cdr.
    swap cons ;

: uncons ( [[ car cdr ]] -- car cdr )
    #! Push both the head and tail of a list.
    dup car swap cdr ;

: unit ( a -- [ a ] )
    #! Construct a proper list of one element.
    f cons ;

: unswons ( [[ car cdr ]] -- cdr car )
    #! Push both the head and tail of a list.
    dup cdr swap car ;

: 2car ( cons cons -- car car )
    swap car swap car ;

: 2cdr ( cons cons -- car car )
    swap cdr swap cdr ;

: 2uncons ( cons1 cons2 -- car1 car2 cdr1 cdr2 )
    [ 2car ] 2keep 2cdr ;

: last* ( list -- last )
    #! Last cons of a list.
    dup cdr cons? [ cdr last* ] when ;

: last ( list -- last )
    #! Last element of a list.
    last* car ;

UNION: general-list f cons ;

PREDICATE: general-list list ( list -- ? )
    #! Proper list test. A proper list is either f, or a cons
    #! cell whose cdr is a proper list.
    dup [ last* cdr ] when not ;

: with ( obj quot elt -- obj quot )
    #! Utility word for each-with, map-with.
    pick pick >r >r swap call r> r> ; inline

: all? ( list pred -- ? )
    #! Push if the predicate returns true for each element of
    #! the list.
    over [
        dup >r swap uncons >r swap call [
            r> r> all?
        ] [
            r> drop r> drop f
        ] ifte
    ] [
        2drop t
    ] ifte ; inline

: all-with? ( obj list pred -- ? )
    swap [ with rot ] all? 2nip ; inline

: (each) ( list quot -- list quot )
    [ >r car r> call ] 2keep >r cdr r> ; inline

: each ( list quot -- )
    #! Push each element of a proper list in turn, and apply a
    #! quotation with effect ( elt -- ) to each element.
    over [ (each) each ] [ 2drop ] ifte ; inline

: each-with ( obj list quot -- )
    #! Push each element of a proper list in turn, and apply a
    #! quotation with effect ( obj elt -- ) to each element.
    swap [ with ] each 2drop ; inline

: subset ( list quot -- list )
    #! Applies a quotation with effect ( X -- ? ) to each
    #! element of a list; all elements for which the quotation
    #! returned a value other than f are collected in a new
    #! list.
    over [
        over car >r (each)
        rot >r subset r> [ r> swons ] [ r> drop ] ifte
    ] [
        drop
    ] ifte ; inline

: subset-with ( obj list quot -- list )
    swap [ with rot ] subset 2nip ; inline

: some? ( list pred -- ? )
    #! Apply predicate with stack effect ( elt -- ? ) to each
    #! element, return remainder of list from first occurrence
    #! where it is true, or return f.
    over [
        dup >r over >r >r car r> call [
            r> r> drop
        ] [
            r> cdr r> some?
        ] ifte
    ] [
        2drop f
    ] ifte ; inline

: some-with? ( obj list pred -- ? )
    #! Apply predicate with stack effect ( obj elt -- ? ) to
    #! each element, return remainder of list from first
    #! occurrence where it is true, or return f.
    swap [ with rot ] some? 2nip ; inline
