! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generic
USING: arrays errors hashtables kernel kernel-internals
namespaces parser sequences strings words vectors math
math-internals ;

: class? ( word -- ? ) "class" word-prop ;

: classes ( -- list ) [ class? ] word-subset ;

SYMBOL: typemap
SYMBOL: builtins

: type>class ( n -- symbol ) builtins get nth ;

: predicate-word ( word -- word )
    word-name "?" append create-in ;

: define-predicate ( class predicate quot -- )
    over [
        dupd define-compound
        2dup unit "predicate" set-word-prop
        swap "predicating" set-word-prop
    ] [
        3drop
    ] if ;

: superclass "superclass" word-prop ;

: members "members" word-prop ;

: (flatten-class) ( class -- )
    dup members [ [ (flatten-class) ] each ] [ dup set ] ?if ;

: flatten-class ( class -- classes )
    [ (flatten-class) ] make-hash ;

: (types) ( class -- )
    flatten-class [
        drop dup superclass
        [ (types) ] [ "type" word-prop dup set ] ?if
    ] hash-each ;

: types ( class -- types )
    [ (types) ] make-hash hash-keys natural-sort ;

DEFER: (class<)

: superclass< ( cls1 cls2 -- ? )
    >r superclass r> 2dup and [ (class<) ] [ 2drop f ] if ;

: union-class< ( cls1 cls2 -- ? )
    [ flatten-class ] 2apply hash-keys swap
    [ drop swap [ (class<) ] contains-with? ] hash-all-with? ;

: class-empty? ( class -- ? )
    members dup [ empty? ] when ;

: (class<) ( cls1 cls2 -- ? )
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ over class-empty? ] [ 2drop t ] }
        { [ 2dup superclass< ] [ 2drop t ] }
        { [ 2dup [ members ] 2apply or not ] [ 2drop f ] }
        { [ t ] [ union-class< ] }
    } cond ;

SYMBOL: class<cache

: class< ( cls1 cls2 -- ? )
    class<cache get [ hash hash-member? ] [ (class<) ] if* ;

: smaller-classes ( class seq -- )
    [ swap (class<) ] subset-with ;

: make-class<cache ( -- hash )
    classes dup [
        2dup swap smaller-classes [ dup ] map>hash
    ] map>hash nip ;

: with-class<cache ( quot -- )
    [ make-class<cache class<cache set call ] with-scope ;
    inline

: class-compare ( cls1 cls2 -- -1/0/1 )
    2dup eq? [ 2drop 0 ] [ class< 1 -1 ? ] if ;

: methods ( generic -- alist )
    "methods" word-prop hash>alist
    [ [ first ] 2apply class-compare ] sort ;

: order ( generic -- list )
    "methods" word-prop hash-keys [ class-compare ] sort ;

PREDICATE: compound generic ( word -- ? )
    "combination" word-prop ;

M: generic definer drop \ G: ;

: make-generic ( word -- )
    dup dup "combination" word-prop call define-compound ;

: check-method ( class generic -- )
    dup generic? [
        dup word-name " is not a generic word" append throw
    ] unless
    over "class" word-prop [
        over word-name " is not a class" append throw
    ] unless 2drop ;

: ?make-generic ( word -- )
    bootstrapping? get
    [ [ ] define-compound ] [ make-generic ] if ;

: with-methods ( word quot -- | quot: methods -- )
    swap [ "methods" word-prop swap call ] keep ?make-generic ;
    inline

: define-method ( definition class generic -- )
    >r bootstrap-word r> 2dup check-method
    [ set-hash ] with-methods ;

: forget-method ( class generic -- )
    [ remove-hash ] with-methods ;

: init-methods ( word -- )
     dup "methods" word-prop
     [ drop ] [ H{ } clone "methods" set-word-prop ] if ;

! Defining generic words

: bootstrap-combination ( quot -- quot )
    global [ [ dup word? [ target-word ] when ] map ] bind ;

: define-generic* ( word combination -- )
    bootstrap-combination
    dupd "combination" set-word-prop
    dup init-methods ?make-generic ;

: lookup-union ( class-set -- class )
    typemap get hash [ object ] unless* ;

: types* ( class -- hash ) types [ type>class dup ] map>hash ;

: (class-and) ( class class -- class )
    [ types* ] 2apply hash-intersect lookup-union ;

: class-and ( class class -- class )
    {
        { [ 2dup class< ] [ drop ] }
        { [ 2dup swap class< ] [ nip ] }
        { [ t ] [ (class-and) ] }
    } cond ;

: classes-intersect? ( class class -- ? )
    class-and class-empty? not ;

: min-class ( class seq -- class/f )
    [ dupd classes-intersect? ] subset dup empty? [
        2drop f
    ] [
        tuck [ class< ] all-with? [ peek ] [ drop f ] if
    ] if ;

: class-forget-hook ( class flattened -- )
    [ typemap get remove-hash ] curry
    "forget-hook" set-word-prop ;

: define-class ( class -- )
    dup t "class" set-word-prop
    dup H{ } clone "class<" set-word-prop
    dup flatten-class
    2dup class-forget-hook
    typemap get set-hash ;

: implementors ( class -- list )
    [ "methods" word-prop ?hash* nip ] word-subset-with ;

! Predicate classes for generalized predicate dispatch.
: define-predicate-class ( class predicate definition -- )
    pick define-class
    3dup nip "definition" set-word-prop
    pick superclass "predicate" word-prop
    [ \ dup , % , [ drop f ] , \ if , ] [ ] make
    define-predicate ;

PREDICATE: word predicate "definition" word-prop ;

! Union classes for dispatch on multiple classes.
: union-predicate ( members -- list )
    [ dup ] swap [ "predicate" word-prop append ] map-with
    [ [ drop t ] 2array ] map [ drop f ] swap alist>quot ;

: set-members ( class members -- )
    [ bootstrap-word ] map "members" set-word-prop ;

: define-union ( class predicate members -- )
    3dup nip set-members pick define-class
    union-predicate define-predicate ;

PREDICATE: word union members ;
