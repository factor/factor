! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generic
USING: arrays definitions errors assocs kernel
kernel-internals namespaces sequences strings words
vectors math quotations ;

PREDICATE: word class ( obj -- ? ) "class" word-prop ;

SYMBOL: typemap
SYMBOL: class<map
SYMBOL: builtins

PREDICATE: word builtin-class ( obj -- ? ) builtins get memq? ;

: tuple-size ( class -- size )
    "slot-names" word-prop length 2 + ;

PREDICATE: class tuple-class "slot-names" word-prop >boolean ;

: classes ( -- seq ) class<map get keys ;

: type>class ( n -- class ) builtins get nth ;

: predicate-word ( word -- predicate )
    [ word-name "?" append ] keep word-vocabulary create ;

: predicate-effect 1 1 <effect> ;

: define-predicate ( class predicate quot -- )
    over [
        dupd predicate-effect define-declared
        2dup 1quotation "predicate" set-word-prop
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
    [ (flatten-class) ] H{ } make-assoc ;

: (explode-class) ( class -- )
    dup superclass [
        (explode-class)
    ] [
        dup members
        [ [ (explode-class) ] each ] [ dup set ] ?if
    ] ?if ;

: explode-class ( class -- seq )
    [ (explode-class) ] H{ } make-assoc ;

: (types) ( class -- )
    explode-class [ drop "type" word-prop dup set ] assoc-each ;

: types ( class -- seq )
    [ (types) ] H{ } make-assoc keys natural-sort ;

DEFER: (class<)

: superclass< ( cls1 cls2 -- ? )
    >r superclass r> 2dup and [ (class<) ] [ 2drop f ] if ;

: union-class< ( cls1 cls2 -- ? )
    [ flatten-class ] 2apply keys swap
    [ drop swap [ (class<) ] contains-with? ] assoc-all-with? ;

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
    class<map get at key? ;

: largest-class ( seq -- n elt )
    dup [ swap [ class< ] subset-with length 1 = ] find-with ;

: (sort-classes) ( vec -- )
    dup empty?
    [ drop ]
    [ dup largest-class , over delete-nth (sort-classes) ] if ;

: sort-classes ( seq -- newseq )
    [ >vector (sort-classes) ] { } make ;

: lookup-union ( classes -- class )
    typemap get at [ object ] unless* ;

: (class-or) ( class class -- class )
    [ explode-class ] 2apply union lookup-union ;

: class-or ( class1 class2 -- class )
    {
        { [ 2dup class< ] [ nip ] }
        { [ 2dup swap class< ] [ drop ] }
        { [ t ] [ (class-or) ] }
    } cond ;

: (class-and) ( class class -- class )
    [ explode-class ] 2apply intersect lookup-union ;

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
    [ smaller-classes [ dup ] H{ } map>assoc ] keep
    class<map get set-at ;

: bigger-classes ( class -- seq )
    classes [ (class<) ] subset-with ;

: bigger-classes+ ( class -- )
    dup bigger-classes
    [ dupd class<map get at set-at ] each-with ;

: define-class ( class -- )
    dup intern-symbol
    dup t "class" set-word-prop
    dup dup flatten-class typemap get set-at
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
    [ "predicate" word-prop \ dup add* [ drop t ] ] { } map>assoc
    [ drop f ] swap alist>quot ;

: set-members ( class members -- )
    [ bootstrap-word ] map "members" set-word-prop ;

: (define-union-class) ( class members -- )
    dupd set-members define-class ;

: define-union-class ( class members -- )
    2dup (define-union-class)
    >r dup predicate-word r>
    union-predicate-quot define-predicate ;

: smaller-classes- ( class -- )
    class<map get delete-at ;

: bigger-classes- ( class -- )
    classes [ class<map get at delete-at ] each-with ;

: uncache-class ( class -- )
    dup flatten-class typemap get delete-at
    dup smaller-classes-
    bigger-classes- ;
