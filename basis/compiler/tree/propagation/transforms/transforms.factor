! Copyright (C) 2008, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences words fry generic accessors
classes.tuple classes classes.algebra definitions
stack-checker.state quotations classes.tuple.private math
math.partial-dispatch math.private math.intervals
math.floats.private math.integers.private layouts math.order
vectors hashtables combinators effects generalizations assocs
sets combinators.short-circuit sequences.private locals
stack-checker namespaces compiler.tree.propagation.info ;
IN: compiler.tree.propagation.transforms

\ equal? [
    ! If first input has a known type and second input is an
    ! object, we convert this to [ swap equal? ].
    in-d>> first2 value-info class>> object class= [
        value-info class>> \ equal? method-for-class
        [ swap equal? ] f ?
    ] [ drop f ] if
] "custom-inlining" set-word-prop

: rem-custom-inlining ( #call -- quot/f )
    second value-info literal>> dup integer?
    [ power-of-2? [ 1 - bitand ] f ? ] [ drop f ] if ;

{
    mod-integer-integer
    mod-integer-fixnum
    mod-fixnum-integer
    fixnum-mod
} [
    [
        in-d>> dup first value-info interval>> [0,inf] interval-subset?
        [ rem-custom-inlining ] [ drop f ] if
    ] "custom-inlining" set-word-prop
] each

\ rem [
    in-d>> rem-custom-inlining
] "custom-inlining" set-word-prop

: positive-fixnum? ( obj -- ? )
    { [ fixnum? ] [ 0 >= ] } 1&& ;

: simplify-bitand? ( value -- ? )
    value-info literal>> positive-fixnum? ;

{
    bitand-integer-integer
    bitand-integer-fixnum
    bitand-fixnum-integer
    bitand
} [
    [
        {
            {
                [ dup in-d>> first simplify-bitand? ]
                [ drop [ >fixnum fixnum-bitand ] ]
            }
            {
                [ dup in-d>> second simplify-bitand? ]
                [ drop [ [ >fixnum ] dip fixnum-bitand ] ]
            }
            [ drop f ]
        } cond
    ] "custom-inlining" set-word-prop
] each

! Speeds up 2^
\ shift [
    in-d>> first value-info literal>> 1 = [
        cell-bits tag-bits get - 1 -
        '[
            >fixnum dup 0 < [ 2drop 0 ] [
                dup _ < [ fixnum-shift ] [
                    fixnum-shift
                ] if
            ] if
        ]
    ] [ f ] if
] "custom-inlining" set-word-prop

{ /i fixnum/i fixnum/i-fast bignum/i } [
    [
        in-d>> first2 [ value-info ] bi@ {
            [ drop class>> integer class<= ]
            [ drop interval>> 0 [a,a] interval>= ]
            [ nip literal>> integer? ]
            [ nip literal>> power-of-2? ]
        } 2&& [ [ log2 neg shift ] ] [ f ] if
    ] "custom-inlining" set-word-prop
] each

! Integrate this with generic arithmetic optimization instead?
: both-inputs? ( #call class -- ? )
    [ in-d>> first2 ] dip '[ value-info class>> _ class<= ] both? ;

\ min [
    {
        { [ dup fixnum both-inputs? ] [ [ fixnum-min ] ] }
        { [ dup float both-inputs? ] [ [ float-min ] ] }
        [ f ]
    } cond nip
] "custom-inlining" set-word-prop

\ max [
    {
        { [ dup fixnum both-inputs? ] [ [ fixnum-max ] ] }
        { [ dup float both-inputs? ] [ [ float-max ] ] }
        [ f ]
    } cond nip
] "custom-inlining" set-word-prop

! Generate more efficient code for common idiom
\ clone [
    in-d>> first value-info literal>> {
        { V{ } [ [ drop { } 0 vector boa ] ] }
        { H{ } [ [ drop 0 <hashtable> ] ] }
        [ drop f ]
    } case
] "custom-inlining" set-word-prop

ERROR: bad-partial-eval quot word ;

: check-effect ( quot word -- )
    2dup [ infer ] [ stack-effect ] bi* effect<=
    [ 2drop ] [ bad-partial-eval ] if ;

:: define-partial-eval ( word quot n -- )
    word [
        in-d>> n tail*
        [ value-info ] map
        dup [ literal?>> ] all? [
            [ literal>> ] map
            n firstn
            quot call dup [
                [ n ndrop ] prepose
                dup word check-effect
            ] when
        ] [ drop f ] if
    ] "custom-inlining" set-word-prop ;

: inline-new ( class -- quot/f )
    dup tuple-class? [
        dup inlined-dependency depends-on
        [ all-slots [ initial>> literalize ] map ]
        [ tuple-layout '[ _ <tuple-boa> ] ]
        bi append >quotation
    ] [ drop f ] if ;

\ new [ inline-new ] 1 define-partial-eval

\ instance? [
    dup class?
    [ "predicate" word-prop ] [ drop f ] if
] 1 define-partial-eval

! Shuffling
: nths-quot ( indices -- quot )
    [ [ '[ _ swap nth ] ] map ] [ length ] bi
    '[ _ cleave _ narray ] ;

\ shuffle [
    shuffle-mapping nths-quot
] 1 define-partial-eval

! Index search
\ index [
    dup sequence? [
        dup length 4 >= [
            dup length zip >hashtable '[ _ at ]
        ] [ drop f ] if
    ] [ drop f ] if
] 1 define-partial-eval

: memq-quot ( seq -- newquot )
    [ [ dupd eq? ] curry [ drop t ] ] { } map>assoc
    [ drop f ] suffix [ cond ] curry ;

\ memq? [
    dup sequence? [ memq-quot ] [ drop f ] if
] 1 define-partial-eval

! Membership testing
: member-quot ( seq -- newquot )
    dup length 4 <= [
        [ drop f ] swap
        [ literalize [ t ] ] { } map>assoc linear-case-quot
    ] [
        unique [ key? ] curry
    ] if ;

\ member? [
    dup sequence? [ member-quot ] [ drop f ] if
] 1 define-partial-eval

! Fast at for integer maps
CONSTANT: lookup-table-at-max 256

: lookup-table-at? ( assoc -- ? )
    #! Can we use a fast byte array test here?
    {
        [ assoc-size 4 > ]
        [ values [ ] all? ]
        [ keys [ integer? ] all? ]
        [ keys [ 0 lookup-table-at-max between? ] all? ]
    } 1&& ;

: lookup-table-seq ( assoc -- table )
    [ keys supremum 1 + ] keep '[ _ at ] { } map-as ;

: lookup-table-quot ( seq -- newquot )
    lookup-table-seq
    '[
        _ over integer? [
            2dup bounds-check? [
                nth-unsafe dup >boolean
            ] [ 2drop f f ] if
        ] [ 2drop f f ] if
    ] ;

: fast-lookup-table-at? ( assoc -- ? )
    values {
        [ [ integer? ] all? ]
        [ [ 0 254 between? ] all? ]
    } 1&& ;

: fast-lookup-table-seq ( assoc -- table )
    lookup-table-seq [ 255 or ] B{ } map-as ;

: fast-lookup-table-quot ( seq -- newquot )
    fast-lookup-table-seq
    '[
        _ over integer? [
            2dup bounds-check? [
                nth-unsafe dup 255 eq? [ drop f f ] [ t ] if
            ] [ 2drop f f ] if
        ] [ 2drop f f ] if
    ] ;

: at-quot ( assoc -- quot )
    dup assoc? [
        dup lookup-table-at? [
            dup fast-lookup-table-at? [
                fast-lookup-table-quot
            ] [
                lookup-table-quot
            ] if
        ] [ drop f ] if
    ] [ drop f ] if ;

\ at* [ at-quot ] 1 define-partial-eval
