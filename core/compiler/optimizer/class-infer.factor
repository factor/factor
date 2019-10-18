! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: class-inference
USING: arrays generic hashtables inference kernel
math namespaces sequences words parser ;

! A constraint is a statement about a value.

! We need a notion of equality which doesn't recurse so cannot
! infinite loop on circular data
GENERIC: eql? ( obj1 obj2 -- ? )
M: object eql? eq? ;
M: number eql? number= ;

! Maps constraints to constraints
SYMBOL: constraints

TUPLE: literal-constraint literal value ;

M: literal-constraint equal?
    over literal-constraint? [
        2dup
        [ literal-constraint-literal ] 2apply eql? >r
        [ literal-constraint-value ] 2apply = r> and
    ] [
        2drop f
    ] if ;

TUPLE: class-constraint class value ;

GENERIC: apply-constraint ( constraint -- )
GENERIC: constraint-satisfied? ( constraint -- ? )

: `input pick node-in-d nth ;
: `output pick node-out-d nth ;
: class, <class-constraint> , ;
: literal, <literal-constraint> , ;

M: f apply-constraint drop ;

: make-constraints ( node quot -- constraint )
    { } make nip ; inline

: set-constraints ( node quot -- )
    make-constraints
    unclip [ 2array ] reduce
    apply-constraint ; inline

: node-class# ( node n -- class )
    over node-in-d <reversed> ?nth node-class ;

! Variables used by the class inferencer

! Current value --> class mapping
SYMBOL: value-classes

! Current value --> literal mapping
SYMBOL: value-literals

: set-value-class* ( class value -- )
    2dup <class-constraint> constraints get hash
    [ apply-constraint ] when*
    value-classes get set-hash ;

M: class-constraint apply-constraint
    dup class-constraint-class
    swap class-constraint-value set-value-class* ;

: set-value-literal* ( literal value -- )
    over class over set-value-class*
    2dup <literal-constraint> constraints get hash
    [ apply-constraint ] when*
    value-literals get set-hash ;

M: literal-constraint apply-constraint
    dup literal-constraint-literal
    swap literal-constraint-value set-value-literal* ;

! For conditionals, an assoc of child node # --> constraint
GENERIC: child-constraints ( node -- seq )

GENERIC: infer-classes-before ( node -- )

GENERIC: infer-classes-around ( node -- )

M: node infer-classes-before drop ;

M: node child-constraints node-children length f <array> ;

: value-class* ( value -- class )
    value-classes get hash [ object ] unless* ;

M: class-constraint constraint-satisfied?
    dup class-constraint-value value-class*
    swap class-constraint-class class< ;

: value-literal* ( value -- obj ? )
    value-literals get hash* ;

M: literal-constraint constraint-satisfied?
    dup literal-constraint-value value-literal*
    [ swap literal-constraint-literal eql? ] [ 2drop f ] if ;

M: pair apply-constraint
    first2 2dup constraints get set-hash
    constraint-satisfied? [ apply-constraint ] [ drop ] if ;

M: pair constraint-satisfied?
    first constraint-satisfied? ;

: annotate-node ( node -- )
    #! Annotate the node with the currently-inferred set of
    #! value classes.
    dup node-values
    [ dup value-class* ] map>hash swap set-node-classes ;

: intersect-classes ( classes values -- )
    [
        [ value-class* class-and ] keep set-value-class*
    ] 2each ;

: predicate-constraints ( #call class -- )
    [
        0 `input class,
        general-t 0 `output class,
    ] set-constraints ;

: compute-constraints ( #call -- )
    dup node-param "constraints" word-prop dup [
        call
    ] [
        drop dup node-param "predicating" word-prop dup [
            predicate-constraints
        ] [
            2drop
        ] if
    ] if ;

: output-classes ( node -- seq )
    dup node-param "output-classes" word-prop [
        call
    ] [
        node-param "inferred-effect" word-prop effect-out
        dup [ word? ] all? [ drop f ] unless
    ] if* ;

M: #call infer-classes-before
    dup compute-constraints
    dup output-classes
    [ swap node-out-d intersect-classes ] [ drop ] if* ;

M: #push infer-classes-before
    node-out-d
    [ [ value-literal ] keep set-value-literal* ] each ;

M: #if child-constraints
    [
        general-t 0 `input class,
        f 0 `input literal,
    ] make-constraints ;

M: #dispatch child-constraints
    [
        dup node-children length [
            0 `input literal,
        ] each
    ] make-constraints ;

M: #declare infer-classes-before
    dup node-param swap node-in-d [ set-value-class* ] 2each ;

DEFER: (infer-classes)

: infer-children ( node -- )
    dup node-children swap child-constraints [
        [
            value-classes [ clone ] change
            value-literals [ clone ] change
            constraints [ clone ] change
            apply-constraint
            (infer-classes)
        ] with-scope
    ] 2each ;

: merge-value-class ( n nodes -- class )
    null [ pick node-class# class-or ] reduce nip ;

: annotate-merge ( nodes #merge/#entry -- )
    node-out-d <reversed> dup length
    [ pick merge-value-class swap set-value-class* ] 2each
    drop ;

: active-children ( node -- seq )
    node-children
    [ last-node ] map
    [ #terminate? not ] subset ;

: merge-children ( node -- )
    dup node-successor dup #merge? [
        swap active-children dup empty?
        [ 2drop ] [ swap annotate-merge ] if
    ] [
        2drop
    ] if ;

: annotate-entry ( nodes #label -- )
    node-child annotate-merge ;

M: #label infer-classes-before ( #label -- )
    #! First, infer types under the hypothesis which hold on
    #! entry to the recursive label.
    dup 1array swap annotate-entry ;

M: #label infer-classes-around ( #label -- )
    #! Now merge the types at every recursion point with the
    #! entry types.
    dup annotate-node
    dup infer-classes-before
    dup infer-children
    dup collect-recursion over add
    pick annotate-entry
    dup infer-children
    merge-children ;

M: object infer-classes-around
    dup infer-classes-before
    dup annotate-node
    dup infer-children
    merge-children ;

: (infer-classes) ( node -- )
    [
        dup infer-classes-around
        node-successor (infer-classes)
    ] when* ;

: ?<hashtable> [ H{ } clone ] unless* ;

: infer-classes-with ( node classes literals -- )
    [
        ?<hashtable> value-literals set
        ?<hashtable> value-classes set
        H{ } clone constraints set
        (infer-classes)
    ] with-scope ;

: infer-classes ( node -- )
    f f infer-classes-with ;

: infer-classes/node ( existing node -- )
    #! Infer classes, using the existing node's class info as a
    #! starting point.
    over node-classes rot node-literals infer-classes-with ;
