! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs hashtables inference kernel
math namespaces sequences words parser math.intervals
effects classes inference.dataflow inference.backend ;
IN: inference.class

! Class inference

! A constraint is a statement about a value.

! We need a notion of equality which doesn't recurse so cannot
! infinite loop on circular data
GENERIC: eql? ( obj1 obj2 -- ? )
M: object eql? eq? ;
M: number eql? number= ;

! Maps constraints to constraints
SYMBOL: constraints

TUPLE: literal-constraint literal value ;

C: <literal-constraint> literal-constraint

M: literal-constraint equal?
    over literal-constraint? [
        2dup
        [ literal-constraint-literal ] 2apply eql? >r
        [ literal-constraint-value ] 2apply = r> and
    ] [
        2drop f
    ] if ;

TUPLE: class-constraint class value ;

C: <class-constraint> class-constraint

TUPLE: interval-constraint interval value ;

C: <interval-constraint> interval-constraint

GENERIC: apply-constraint ( constraint -- )
GENERIC: constraint-satisfied? ( constraint -- ? )

: `input node get node-in-d nth ;
: `output node get node-out-d nth ;
: class, <class-constraint> , ;
: literal, <literal-constraint> , ;
: interval, <interval-constraint> , ;

M: f apply-constraint drop ;

: make-constraints ( node quot -- constraint )
    [ swap node set call ] { } make ; inline

: set-constraints ( node quot -- )
    make-constraints
    unclip [ 2array ] reduce
    apply-constraint ; inline

: assume ( constraint -- )
    constraints get at [ apply-constraint ] when* ;

! Variables used by the class inferencer

! Current value --> literal mapping
SYMBOL: value-literals

! Current value --> interval mapping
SYMBOL: value-intervals

! Current value --> class mapping
SYMBOL: value-classes

: set-value-interval* ( interval value -- )
    value-intervals get set-at ;

M: interval-constraint apply-constraint
    dup interval-constraint-interval
    swap interval-constraint-value set-value-interval* ;

: set-class-interval ( class value -- )
    >r "interval" word-prop dup
    [ r> set-value-interval* ] [ r> 2drop ] if ;

: set-value-class* ( class value -- )
    over [
        dup value-intervals get at [
            2dup set-class-interval
        ] unless
        2dup <class-constraint> assume
    ] when
    value-classes get set-at ;

M: class-constraint apply-constraint
    dup class-constraint-class
    swap class-constraint-value set-value-class* ;

: set-value-literal* ( literal value -- )
    over class over set-value-class*
    over real? [ over [a,a] over set-value-interval* ] when
    2dup <literal-constraint> assume
    value-literals get set-at ;

M: literal-constraint apply-constraint
    dup literal-constraint-literal
    swap literal-constraint-value set-value-literal* ;

! For conditionals, an assoc of child node # --> constraint
GENERIC: child-constraints ( node -- seq )

GENERIC: infer-classes-before ( node -- )

GENERIC: infer-classes-around ( node -- )

M: node infer-classes-before drop ;

M: node child-constraints
    node-children length
    dup zero? [ drop f ] [ f <repetition> ] if ;

: value-literal* ( value -- obj ? )
    value-literals get at* ;

M: literal-constraint constraint-satisfied?
    dup literal-constraint-value value-literal*
    [ swap literal-constraint-literal eql? ] [ 2drop f ] if ;

: value-class* ( value -- class )
    value-classes get at object or ;

M: class-constraint constraint-satisfied?
    dup class-constraint-value value-class*
    swap class-constraint-class class< ;

: value-interval* ( value -- interval/f )
    value-intervals get at ;

M: pair apply-constraint
    first2 2dup constraints get set-at
    constraint-satisfied? [ apply-constraint ] [ drop ] if ;

M: pair constraint-satisfied?
    first constraint-satisfied? ;

: extract-keys ( assoc seq -- newassoc )
    dup length <hashtable> swap [
        dup >r pick at* [ r> pick set-at ] [ r> 2drop ] if
    ] each nip f assoc-like ;

: annotate-node ( node -- )
    #! Annotate the node with the currently-inferred set of
    #! value classes.
    dup node-values
    value-intervals get over extract-keys pick set-node-intervals
    value-classes get over extract-keys pick set-node-classes
    value-literals get over extract-keys pick set-node-literals
    2drop ;

: intersect-classes ( classes values -- )
    [ [ value-class* class-and ] keep set-value-class* ] 2each ;

: intersect-intervals ( intervals values -- )
    [
        [ value-interval* interval-intersect ] keep
        set-value-interval*
    ] 2each ;

: predicate-constraints ( class #call -- )
    [
        0 `input class,
        general-t 0 `output class,
    ] set-constraints ;

: compute-constraints ( #call -- )
    dup node-param "constraints" word-prop [
        call
    ] [
        dup node-param "predicating" word-prop dup
        [ swap predicate-constraints ] [ 2drop ] if
    ] if* ;

: default-output-classes ( word -- classes )
    "inferred-effect" word-prop effect-out
    dup [ class? ] all? [ drop f ] unless ;

: compute-output-classes ( node word -- classes intervals )
    dup node-param "output-classes" word-prop dup
    [ call ] [ 2drop f f ] if ;

: output-classes ( node -- classes intervals )
    dup compute-output-classes
    >r [ ] [ node-param default-output-classes ] ?if r> ;

M: #call infer-classes-before
    dup compute-constraints
    dup node-out-d swap output-classes
    >r over intersect-classes
    r> swap intersect-intervals ;

M: #push infer-classes-before
    node-out-d
    [ [ value-literal ] keep set-value-literal* ] each ;

M: #if child-constraints
    [
        general-t 0 `input class,
        f 0 `input literal,
    ] make-constraints ;

M: #dispatch child-constraints
    dup [
        node-children length [
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
            value-intervals [ clone ] change
            constraints [ clone ] change
            apply-constraint
            (infer-classes)
        ] with-scope
    ] 2each ;

: pad-all ( seqs elt -- seq )
    >r dup [ length ] map supremum r> [ pad-left ] 2curry map ;

: (merge-classes) ( nodes -- seq )
    [ node-input-classes ] map
    null pad-all flip [ null [ class-or ] reduce ] map ;

: set-classes ( seq node -- )
    node-out-d [ set-value-class* ] 2reverse-each ;

: merge-classes ( nodes node -- )
    >r (merge-classes) r> set-classes ;

: (merge-intervals) ( nodes quot -- seq )
    >r
    [ node-input-intervals ] map
    f pad-all flip
    r> map ; inline

: set-intervals ( seq node -- )
    node-out-d [ set-value-interval* ] 2reverse-each ;

: merge-intervals ( nodes node -- )
    >r [ dup first [ interval-union ] reduce ]
    (merge-intervals) r> set-intervals ;

: annotate-merge ( nodes #merge/#entry -- )
    2dup merge-classes merge-intervals ;

: merge-children ( node -- )
    dup node-successor dup #merge? [
        swap active-children dup empty?
        [ 2drop ] [ swap annotate-merge ] if
    ] [
        2drop
    ] if ;

: annotate-entry ( nodes #label -- )
    node-child merge-classes ;

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
    node-child (infer-classes) ;

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

: infer-classes-with ( node classes literals intervals -- )
    [
        H{ } assoc-like value-intervals set
        H{ } assoc-like value-literals set
        H{ } assoc-like value-classes set
        H{ } clone constraints set
        (infer-classes)
    ] with-scope ;

: infer-classes ( node -- )
    f f f infer-classes-with ;

: infer-classes/node ( node existing -- )
    #! Infer classes, using the existing node's class info as a
    #! starting point.
    dup node-classes
    over node-literals
    rot node-intervals
    infer-classes-with ;
