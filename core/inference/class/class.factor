! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs hashtables inference kernel
math namespaces sequences words parser math.intervals
effects classes classes.algebra inference.dataflow
inference.backend combinators accessors ;
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
        [ [ literal>> ] bi@ eql? ]
        [ [ value>>   ] bi@ =    ]
        2bi and
    ] [ 2drop f ] if ;

TUPLE: class-constraint class value ;

C: <class-constraint> class-constraint

TUPLE: interval-constraint interval value ;

C: <interval-constraint> interval-constraint

GENERIC: apply-constraint ( constraint -- )
GENERIC: constraint-satisfied? ( constraint -- ? )

: `input node get in-d>> nth ;
: `output node get out-d>> nth ;
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

: value-interval* ( value -- interval/f )
    value-intervals get at ;

: set-value-interval* ( interval value -- )
    value-intervals get set-at ;

: intersect-value-interval ( interval value -- )
    [ value-interval* interval-intersect ] keep
    set-value-interval* ;

M: interval-constraint apply-constraint
    [ interval>> ] [ value>> ] bi intersect-value-interval ;

: set-class-interval ( class value -- )
    over class? [
        >r "interval" word-prop r> over
        [ set-value-interval* ] [ 2drop ] if
    ] [ 2drop ] if ;

: value-class* ( value -- class )
    value-classes get at object or ;

: set-value-class* ( class value -- )
    over [
        dup value-intervals get at [
            2dup set-class-interval
        ] unless
        2dup <class-constraint> assume
    ] when
    value-classes get set-at ;

: intersect-value-class ( class value -- )
    [ value-class* class-and ] keep set-value-class* ;

M: class-constraint apply-constraint
    [ class>> ] [ value>> ] bi intersect-value-class ;

: literal-interval ( value -- interval/f )
    dup real? [ [a,a] ] [ drop f ] if ;

: set-value-literal* ( literal value -- )
    {
        [ >r class r> set-value-class* ]
        [ >r literal-interval r> set-value-interval* ]
        [ <literal-constraint> assume ]
        [ value-literals get set-at ]
    } 2cleave ;

M: literal-constraint apply-constraint
    [ literal>> ] [ value>> ] bi set-value-literal* ;

! For conditionals, an assoc of child node # --> constraint
GENERIC: child-constraints ( node -- seq )

GENERIC: infer-classes-before ( node -- )

GENERIC: infer-classes-around ( node -- )

M: node infer-classes-before drop ;

M: node child-constraints
    children>> length
    dup zero? [ drop f ] [ f <repetition> ] if ;

: value-literal* ( value -- obj ? )
    value-literals get at* ;

M: literal-constraint constraint-satisfied?
    dup value>> value-literal*
    [ swap literal>> eql? ] [ 2drop f ] if ;

M: class-constraint constraint-satisfied?
    [ value>> value-class* ] [ class>> ] bi class<= ;

M: pair apply-constraint
    first2 2dup constraints get set-at
    constraint-satisfied? [ apply-constraint ] [ drop ] if ;

M: pair constraint-satisfied?
    first constraint-satisfied? ;

: extract-keys ( seq assoc -- newassoc )
    [ dupd at ] curry H{ } map>assoc [ nip ] assoc-filter f assoc-like ;

: annotate-node ( node -- )
    #! Annotate the node with the currently-inferred set of
    #! value classes.
    dup node-values {
        [ value-intervals get extract-keys >>intervals ]
        [ value-classes   get extract-keys >>classes   ]
        [ value-literals  get extract-keys >>literals  ]
        [ 2drop ]
    } cleave ;

: intersect-classes ( classes values -- )
    [ intersect-value-class ] 2each ;

: intersect-intervals ( intervals values -- )
    [ intersect-value-interval ] 2each ;

: predicate-constraints ( class #call -- )
    [
        ! If word outputs true, input is an instance of class
        [
            0 `input class,
            \ f class-not 0 `output class,
        ] set-constraints
    ] [
        ! If word outputs false, input is not an instance of class
        [
            class-not 0 `input class,
            \ f 0 `output class,
        ] set-constraints
    ] 2bi ;

: compute-constraints ( #call -- )
    dup param>> "constraints" word-prop [
        call
    ] [
        dup param>> "predicating" word-prop dup
        [ swap predicate-constraints ] [ 2drop ] if
    ] if* ;

: compute-output-classes ( node word -- classes intervals )
    dup param>> "output-classes" word-prop
    dup [ call ] [ 2drop f f ] if ;

: output-classes ( node -- classes intervals )
    dup compute-output-classes >r
    [ ] [ param>> "default-output-classes" word-prop ] ?if
    r> ;

M: #call infer-classes-before
    [ compute-constraints ] keep
    [ output-classes ] [ out-d>> ] bi
    tuck [ intersect-classes ] [ intersect-intervals ] 2bi* ;

M: #push infer-classes-before
    out-d>> [ [ value-literal ] keep set-value-literal* ] each ;

M: #if child-constraints
    [
        \ f class-not 0 `input class,
        f 0 `input literal,
    ] make-constraints ;

M: #dispatch child-constraints
    dup [
        children>> length [ 0 `input literal, ] each
    ] make-constraints ;

M: #declare infer-classes-before
    [ param>> ] [ in-d>> ] bi
    [ intersect-value-class ] 2each ;

DEFER: (infer-classes)

: infer-children ( node -- )
    [ children>> ] [ child-constraints ] bi [
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
    dup length 1 = [
        first node-input-classes
    ] [
        [ node-input-classes ] map null pad-all flip
        [ null [ class-or ] reduce ] map
    ] if ;

: set-classes ( seq node -- )
    out-d>> [ set-value-class* ] 2reverse-each ;

: merge-classes ( nodes node -- )
    >r (merge-classes) r> set-classes ;

: set-intervals ( seq node -- )
    out-d>> [ set-value-interval* ] 2reverse-each ;

: merge-intervals ( nodes node -- )
    >r
    [ node-input-intervals ] map f pad-all flip
    [ dup first [ interval-union ] reduce ] map
    r> set-intervals ;

: annotate-merge ( nodes #merge/#entry -- )
    [ merge-classes ] [ merge-intervals ] 2bi ;

: merge-children ( node -- )
    dup node-successor dup #merge? [
        swap active-children dup empty?
        [ 2drop ] [ swap annotate-merge ] if
    ] [ 2drop ] if ;

: classes= ( inferred current -- ? )
    2dup min-length [ tail* ] curry bi@ sequence= ;

SYMBOL: fixed-point?

SYMBOL: nested-labels

: annotate-entry ( nodes #label -- )
    >r (merge-classes) r> node-child
    2dup node-output-classes classes=
    [ 2drop ] [ set-classes fixed-point? off ] if ;

: init-recursive-calls ( #label -- )
    #! We set recursive calls to output the empty type, then
    #! repeat inference until a fixed point is reached.
    #! Hopefully, our type functions are monotonic so this
    #! will always converge.
    returns>> [ dup in-d>> [ null ] { } map>assoc >>classes drop ] each ;

M: #label infer-classes-before ( #label -- )
    [ init-recursive-calls ]
    [ [ 1array ] keep annotate-entry ] bi ;

: infer-label-loop ( #label -- )
    fixed-point? on
    dup node-child (infer-classes)
    dup [ calls>> ] [ suffix ] [ annotate-entry ] tri
    fixed-point? get [ drop ] [ infer-label-loop ] if ;

M: #label infer-classes-around ( #label -- )
    #! Now merge the types at every recursion point with the
    #! entry types.
    [
        {
            [ nested-labels get push ]
            [ annotate-node ]
            [ infer-classes-before ]
            [ infer-label-loop ]
            [ drop nested-labels get pop* ]
        } cleave
    ] with-scope ;

: find-label ( param -- #label )
    param>> nested-labels get [ param>> eq? ] with find nip ;

M: #call-label infer-classes-before ( #call-label -- )
    [ find-label returns>> (merge-classes) ] [ out-d>> ] bi
    [ set-value-class* ] 2each ;

M: #return infer-classes-around
    nested-labels get length 0 > [
        dup param>> nested-labels get peek param>> eq? [
            [ ] [ node-input-classes ] [ in-d>> [ value-class* ] map ] tri
            classes= not [
                fixed-point? off
                [ in-d>> value-classes get extract-keys ] keep
                set-node-classes
            ] [ drop ] if
        ] [ call-next-method ] if
    ] [ call-next-method ] if ;

M: object infer-classes-around
    {
        [ infer-classes-before ]
        [ annotate-node ]
        [ infer-children ]
        [ merge-children ]
    } cleave ;

: (infer-classes) ( node -- )
    [
        [ infer-classes-around ]
        [ node-successor ] bi
        (infer-classes)
    ] when* ;

: infer-classes-with ( node classes literals intervals -- )
    [
        V{ } clone nested-labels set
        H{ } assoc-like value-intervals set
        H{ } assoc-like value-literals set
        H{ } assoc-like value-classes set
        H{ } clone constraints set
        (infer-classes)
    ] with-scope ;

: infer-classes ( node -- node )
    dup f f f infer-classes-with ;

: infer-classes/node ( node existing -- )
    #! Infer classes, using the existing node's class info as a
    #! starting point.
    [ classes>> ] [ literals>> ] [ intervals>> ] tri
    infer-classes-with ;
