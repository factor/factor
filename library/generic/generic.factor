! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: arrays errors hashtables kernel kernel-internals lists
namespaces parser sequences strings words vectors math
math-internals ;

! A simple single-dispatch generic word system.

! Maps lists of builtin type numbers to class objects.
SYMBOL: typemap

! Global vector mapping type numbers to builtin class objects.
SYMBOL: builtins

: type>class ( n -- symbol ) builtins get nth ;

: predicate-word ( word -- word )
    word-name "?" append create-in ;

: define-predicate ( class predicate quot -- )
    #! predicate may be f, in which case it is ignored.
    over [
        dupd define-compound
        2dup unit "predicate" set-word-prop
        swap "predicating" set-word-prop
    ] [
        3drop
    ] ifte ;

: superclass "superclass" word-prop ;

: members "members" word-prop ;

: (flatten) ( class -- )
    dup members [ [ (flatten) ] each ] [ dup set ] ?ifte ;

: flatten ( class -- classes )
    #! Outputs a sequence of classes whose union is this class.
    [ (flatten) ] make-hash ;

DEFER: types

: (types) ( class -- )
    #! Only valid for a flattened class.
    dup superclass [ types % ] [ "type" word-prop , ] ?ifte ;

: types ( class -- types )
    [ flatten hash-keys [ (types) ] each ] { } make prune ;

DEFER: class<

: superclass< ( cls1 cls2 -- ? )
    >r superclass r> over [ class< ] [ 2drop f ] ifte ;

: (class<) ( cls1 cls2 -- ? )
    [ flatten hash-keys ] 2apply
    swap [ swap [ class< ] contains-with? ] all-with? ;

: class< ( cls1 cls2 -- ? )
    #! Test if class1 is a subclass of class2.
    @{
        @{ [ 2dup eq? ] [ 2drop t ] }@
        @{ [ over flatten hash-size 0 = ] [ 2drop t ] }@
        @{ [ over superclass ] [ >r superclass r> class< ] }@
        @{ [ dup superclass ] [ superclass< ] }@
        @{ [ 2dup [ members ] 2apply or not ] [ 2drop f ] }@
        @{ [ t ] [ (class<) ] }@
    }@ cond ;

: class-compare ( cls1 cls2 -- -1/0/1 )
    2dup eq? [ 2drop 0 ] [ class< 1 -1 ? ] ifte ;

: methods ( generic -- alist )
    "methods" word-prop hash>alist [ 2car class-compare ] sort ;

: order ( generic -- list )
    methods [ car ] map ;

PREDICATE: compound generic ( word -- ? )
    "combination" word-prop ;

M: generic definer drop \ G: ;

: make-generic ( word -- )
    dup dup "combination" word-prop call define-compound ;

: class? ( word -- ? ) "class" word-prop ;

: check-method ( class generic -- )
    dup generic? [
        dup word-name " is not a generic word" append throw
    ] unless
    over "class" word-prop [
        over word-name " is not a class" append throw
    ] unless 2drop ;

: define-method ( definition class generic -- )
    >r reintern r> 2dup check-method
    [ "methods" word-prop set-hash ] keep make-generic ;

: forget-method ( class generic -- )
    [ "methods" word-prop remove-hash ] keep make-generic ;

: init-methods ( word -- )
     dup "methods" word-prop
     [ drop ] [ {{ }} clone "methods" set-word-prop ] ifte ;

! Defining generic words

: bootstrap-combination ( quot -- quot )
    #! Bootstrap hack.
    global [
        [
            dup word? [
                dup word-name swap word-vocabulary lookup
            ] when
        ] map
    ] bind ;

: define-generic* ( word combination -- )
    bootstrap-combination
    dupd "combination" set-word-prop
    dup init-methods make-generic ;

: lookup-union ( class-set -- class )
    #! The class set is a hashtable with equal keys/values.
    typemap get hash [ object ] unless* ;

: (builtin-supertypes) ( class -- )
    dup members [
        [ (builtin-supertypes) ] each
    ] [
        dup superclass [
            (builtin-supertypes)
        ] [
            dup set
        ] ?ifte
    ] ?ifte ;

: builtin-supertypes ( class -- classes )
    #! Outputs a sequence of builtin classes whose union is the
    #! smallest union of builtin classes that contains this
    #! class.
    [ (builtin-supertypes) ] make-hash ;

: (class-and) ( class class -- class )
    [ builtin-supertypes ] 2apply hash-intersect lookup-union ;

: class-and ( class class -- class )
    #! Return a class that is a subclass of both, or null in
    #! the degenerate case.
    @{
        @{ [ 2dup class< ] [ drop ] }@
        @{ [ 2dup swap class< ] [ nip ] }@
        @{ [ t ] [ (class-and) ] }@
    }@ cond ;

: classes-intersect? ( class class -- ? )
    class-and flatten hash-size 0 > ;

: min-class ( class seq -- class/f )
    #! Is this class the smallest class in the sequence?
    [ dupd classes-intersect? ] subset
    [ class-compare neg ] sort
    tuck [ class< ] all-with? [ first ] [ drop f ] ifte ;

: define-class ( class -- )
    dup t "class" set-word-prop
    dup flatten typemap get set-hash ;

: implementors ( class -- list )
    #! Find a list of generics that implement a method
    #! specializing on this class.
    [ "methods" word-prop ?hash ] word-subset-with ;

: classes ( -- list )
    #! Output a list of all defined classes.
    [ class? ] word-subset ;

! Predicate classes for generalized predicate dispatch.
: define-predicate-class ( class predicate definition -- )
    pick define-class
    3dup nip "definition" set-word-prop
    pick superclass "predicate" word-prop
    [ \ dup , % , [ drop f ] , \ ifte , ] [ ] make
    define-predicate ;

PREDICATE: word predicate "definition" word-prop ;

! Union classes for dispatch on multiple classes.
: union-predicate ( members -- list )
    [
        "predicate" word-prop \ dup swons [ drop t ] cons
    ] map [ drop f ] swap alist>quot ;

: set-members ( class members -- )
    [ reintern ] map "members" set-word-prop ;

: define-union ( class predicate members -- )
    #! We have to turn the f object into the f word, same for t.
    3dup nip set-members pick define-class
    union-predicate define-predicate ;

PREDICATE: word union members ;
