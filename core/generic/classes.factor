! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generic
USING: arrays definitions errors hashtables kernel
kernel-internals namespaces sequences strings words
vectors math parser ;

PREDICATE: word class ( obj -- ? ) "class" word-prop ;

SYMBOL: typemap
SYMBOL: class<map
SYMBOL: builtins

PREDICATE: word builtin-class ( obj -- ? ) builtins get memq? ;

: tuple-size ( class -- size ) "tuple-size" word-prop ;

PREDICATE: class tuple-class tuple-size >boolean ;

: classes ( -- seq ) class<map get hash-keys ;

: type>class ( n -- class ) builtins get nth ;

: predicate-word ( word -- predicate )
    word-name "?" append create-in ;

: predicate-effect 1 1 <effect> ;

: define-predicate ( class predicate quot -- )
    over [
        over predicate-effect "declared-effect" set-word-prop
        dupd define-compound
        2dup unit "predicate" set-word-prop
        swap "predicating" set-word-prop
    ] [
        3drop
    ] if ;

: superclass ( class -- super ) "superclass" word-prop ;

: set-superclass ( superclass class -- )
    swap "superclass" set-word-prop ;

: members ( class -- seq ) "members" word-prop ;

PREDICATE: class union-class members >boolean ;

: (flatten-class) ( class -- )
    dup members [ [ (flatten-class) ] each ] [ dup set ] ?if ;

: flatten-class ( class -- hash )
    [ (flatten-class) ] make-hash ;

: (explode-class) ( class -- )
    dup superclass [
        (explode-class)
    ] [
        dup members
        [ [ (explode-class) ] each ] [ dup set ] ?if
    ] ?if ;

: explode-class ( class -- seq )
    [ (explode-class) ] make-hash ;

: (types) ( class -- )
    explode-class [ drop "type" word-prop dup set ] hash-each ;

: types ( class -- seq )
    [ (types) ] make-hash hash-keys natural-sort ;

DEFER: (class<)

: superclass< ( cls1 cls2 -- ? )
    >r superclass r> 2dup and [ (class<) ] [ 2drop f ] if ;

: union-class< ( cls1 cls2 -- ? )
    [ flatten-class ] 2apply hash-keys swap
    [ drop swap [ (class<) ] contains-with? ] hash-all-with? ;

: class-empty? ( class -- ? ) members dup [ empty? ] when ;

: (class<) ( class1 class2 -- ? )
    {
        { [ 2dup eq? ] [ 2drop t ] }
        { [ over class-empty? ] [ 2drop t ] }
        { [ 2dup superclass< ] [ 2drop t ] }
        { [ 2dup [ union-class? not ] both? ] [ 2drop f ] }
        { [ t ] [ union-class< ] }
    } cond ;

: class< ( class1 class2 -- ? )
    class<map get hash hash-member? ;

: class-compare ( class1 class2 -- n )
    2dup eq? [ 2drop 0 ] [ class< 1 -1 ? ] if ;

: lookup-union ( classes -- class )
    typemap get hash [ object ] unless* ;

: (class-or) ( class class -- class )
    [ explode-class ] 2apply hash-union lookup-union ;

: class-or ( class1 class2 -- class )
    {
        { [ 2dup class< ] [ nip ] }
        { [ 2dup swap class< ] [ drop ] }
        { [ t ] [ (class-or) ] }
    } cond ;

: (class-and) ( class class -- class )
    [ explode-class ] 2apply hash-intersect lookup-union ;

: tuple-class-and ( class1 class2 -- class )
    dupd eq? [ drop null ] unless ;

: class-and ( class1 class2 -- class )
    {
        { [ 2dup class< ] [ drop ] }
        { [ 2dup swap class< ] [ nip ] }
        { [ 2dup [ tuple-class? ] both? ] [ tuple-class-and ] }
        { [ t ] [ (class-and) ] }
    } cond ;

: classes-intersect? ( class1 class2 -- ? )
    class-and class-empty? not ;

: min-class ( class seq -- class/f )
    [ dupd classes-intersect? ] subset dup empty? [
        2drop f
    ] [
        tuck [ class< ] all-with? [ peek ] [ drop f ] if
    ] if ;

: smaller-classes ( class -- seq )
    classes [ swap (class<) ] subset-with ;

: smaller-classes+ ( class -- )
    [ smaller-classes [ dup ] map>hash ] keep
    class<map get set-hash ;

: bigger-classes ( class -- seq )
    classes [ (class<) ] subset-with ;

: bigger-classes+ ( class -- )
    dup bigger-classes
    [ dupd class<map get hash set-hash ] each-with ;

: define-class ( class -- )
    dup intern-symbol
    dup t "class" set-word-prop
    dup dup flatten-class typemap get set-hash
    dup smaller-classes+ bigger-classes+ ;

! Predicate classes for generalized predicate dispatch.
: predicate-quot ( class -- quot )
    [
        \ dup ,
        dup superclass "predicate" word-prop %
        "definition" word-prop , [ drop f ] , \ if ,
    ] [ ] make ;

: define-predicate-class ( superclass class definition -- )
    >r tuck set-superclass dup r> "definition" set-word-prop
    dup dup predicate-word over predicate-quot define-predicate
    define-class ;

PREDICATE: class predicate-class "definition" word-prop ;

! Union classes for dispatch on multiple classes.
: union-predicate-quot ( seq -- quot )
    [ "predicate" word-prop \ dup add* [ drop t ] 2array ] map
    [ drop f ] swap alist>quot ;

: set-members ( class members -- )
    [ bootstrap-word ] map "members" set-word-prop ;

: (define-union-class) ( class members -- )
    dupd set-members define-class ;

: define-union-class ( class members -- )
    2dup (define-union-class)
    >r dup predicate-word r>
    union-predicate-quot define-predicate ;

! Definition protocol
: smaller-classes- ( class -- )
    class<map get remove-hash ;

: bigger-classes- ( class -- )
    classes [ class<map get hash remove-hash ] each-with ;

: forget-class ( class -- )
    dup subdefs [ forget ] each
    dup "predicate" word-prop [ forget ] each
    dup dup flatten-class typemap get remove-hash forget-word
    dup smaller-classes- bigger-classes- ;

M: class forget forget-class ;
