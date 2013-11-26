! Copyright (C) 2008, 2011 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel sequences words fry generic
generic.single accessors classes.tuple classes classes.algebra
definitions stack-checker.dependencies quotations
classes.tuple.private math math.partial-dispatch math.private
math.intervals sets.private math.floats.private
math.integers.private layouts math.order vectors hashtables
combinators effects generalizations sequences.generalizations
assocs sets combinators.short-circuit sequences.private locals
growable stack-checker namespaces compiler.tree.propagation.info
hash-sets arrays hashtables.private ;
FROM: math => float ;
FROM: sets => set members ;
IN: compiler.tree.propagation.transforms

\ equal? [
    ! If first input has a known type and second input is an
    ! object, we convert this to [ swap equal? ].
    in-d>> first2 value-info class>> object class= [
        value-info class>> \ equal? method-for-class
        [ swap equal? ] f ?
    ] [ drop f ] if
] "custom-inlining" set-word-prop

: rem-custom-inlining ( inputs -- quot/f )
    dup first value-info class>> integer class<= [
        second value-info literal>> dup integer?
        [ power-of-2? [ 1 - bitand ] f ? ] [ drop f ] if
    ] [ drop f ] if ;

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

: non-negative-fixnum? ( obj -- ? )
    { [ fixnum? ] [ 0 >= ] } 1&& ;

: simplify-bitand? ( value1 value2 -- ? )
    [ literal>> non-negative-fixnum? ]
    [ class>> fixnum swap class<= ]
    bi* and ;

: all-ones? ( n -- ? ) dup 1 + bitand zero? ; inline

: redundant-bitand? ( value1 value2 -- ? )
    [ interval>> ] [ literal>> ] bi* {
        [ nip integer? ]
        [ nip all-ones? ]
        [ 0 swap [a,b] interval-subset? ]
    } 2&& ;

: zero-bitand? ( value1 value2 -- ? )
    [ interval>> ] [ literal>> ] bi* {
        [ nip integer? ]
        [ nip bitnot all-ones? ]
        [ 0 swap bitnot [a,b] interval-subset? ]
    } 2&& ;

{
    bitand-integer-integer
    bitand-integer-fixnum
    bitand-fixnum-integer
    bitand
} [
    [
        in-d>> first2 [ value-info ] bi@ {
            {
                [ 2dup zero-bitand? ]
                [ 2drop [ 2drop 0 ] ]
            }
            {
                [ 2dup swap zero-bitand? ]
                [ 2drop [ 2drop 0 ] ]
            }
            {
                [ 2dup redundant-bitand? ]
                [ 2drop [ drop ] ]
            }
            {
                [ 2dup swap redundant-bitand? ]
                [ 2drop [ nip ] ]
            }
            {
                [ 2dup simplify-bitand? ]
                [ 2drop [ integer>fixnum fixnum-bitand ] ]
            }
            {
                [ 2dup swap simplify-bitand? ]
                [ 2drop [ [ integer>fixnum ] dip fixnum-bitand ] ]
            }
            [ 2drop f ]
        } cond
    ] "custom-inlining" set-word-prop
] each

! Speeds up 2^
: 2^? ( #call -- ? )
    in-d>> first value-info literal>> 1 eq? ;

: shift-2^ ( -- quot )
    cell-bits tag-bits get - 1 -
    '[
        integer>fixnum-strict dup 0 < [ 2drop 0 ] [
            dup _ < [ fixnum-shift ] [
                fixnum-shift
            ] if
        ] if
    ] ;

! Speeds up 2/
: 2/? ( #call -- ? )
    in-d>> second value-info literal>> -1 eq? ;

: shift-2/ ( -- quot )
    [
        {
            { [ over fixnum? ] [ fixnum-shift ] }
            { [ over bignum? ] [ bignum-shift ] }
            [ drop \ shift no-method ]
        } cond
    ] ;

\ shift [
    {
        { [ dup 2^? ] [ drop shift-2^ ] }
        { [ dup 2/? ] [ drop shift-2/ ] }
        [ drop f ]
    } cond
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

! Generate more efficient code for common idiom
\ clone [
    in-d>> first value-info literal>> {
        { V{ } [ [ drop { } 0 vector boa ] ] }
        { H{ } [ [ drop 0 0 8 ((empty)) <array> hashtable boa ] ] }
        { HS{ } [ [ drop 0 0 4 ((empty)) <array> hash-set boa ] ] }
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
        dup tuple-layout
        [ add-depends-on-tuple-layout ]
        [ drop all-slots [ initial>> literalize ] [ ] map-as ]
        [ nip ]
        2tri
        '[ @ _ <tuple-boa> ]
    ] [ drop f ] if ;

\ new [ inline-new ] 1 define-partial-eval

\ instance? [
    dup classoid?
    [
        predicate-def
        ! union{ and intersection{ have useless expansions, and recurse infinitely
        dup { [ length 2 >= ] [ second \ instance? = ] } 1&& [
            drop f
        ] when
    ] [ drop f ] if
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
            dup length iota zip >hashtable '[ _ at ]
        ] [ drop f ] if
    ] [ drop f ] if
] 1 define-partial-eval

: member-eq-quot ( seq -- newquot )
    [ [ dupd eq? ] curry [ drop t ] ] { } map>assoc
    [ drop f ] suffix [ cond ] curry ;

\ member-eq? [
    dup sequence? [ member-eq-quot ] [ drop f ] if
] 1 define-partial-eval

! Membership testing
: member-quot ( seq -- newquot )
    dup length 4 <= [
        [ drop f ] swap
        [ literalize [ t ] ] { } map>assoc linear-case-quot
    ] [
        tester
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
    [ keys supremum 1 + iota ] keep '[ _ at ] { } map-as ;

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

: diff-quot ( seq -- quot: ( seq' -- seq'' ) )
    [ tester ] keep '[ members [ @ not ] filter _ set-like ] ;

M\ set diff [ diff-quot ] 1 define-partial-eval

: intersect-quot ( seq -- quot: ( seq' -- seq'' ) )
    [ tester ] keep '[ members _ filter _ set-like ] ;

M\ set intersect [ intersect-quot ] 1 define-partial-eval

: intersects?-quot ( seq -- quot: ( seq' -- seq'' ) )
    tester '[ members _ any? ] ;

M\ set intersects? [ intersects?-quot ] 1 define-partial-eval

: bit-quot ( #call -- quot/f )
    in-d>> second value-info interval>> 0 fixnum-bits [a,b] interval-subset?
    [ [ integer>fixnum ] dip fixnum-bit? ] f ? ;

\ bit? [ bit-quot ] "custom-inlining" set-word-prop

! Speeds up sum-file, sort and reverse-complement benchmarks by
! compiling decoder-readln better
\ push [
    in-d>> second value-info class>> growable class<=
    [ \ push def>> ] [ f ] if
] "custom-inlining" set-word-prop

: custom-inline-fixnum ( #call method -- y )
    [ in-d>> first value-info class>> fixnum \ f class-or class<= ] dip
    '[ [ dup [ _ no-method ] unless ] ] [ f ] if ;

! Speeds up fasta benchmark
{ >fixnum integer>fixnum integer>fixnum-strict } [
    dup '[ _ custom-inline-fixnum ] "custom-inlining" set-word-prop
] each

! We want to constant-fold calls to heap-size, and recompile those
! calls when a C type is redefined
\ heap-size [
    [ add-depends-on-c-type ] [ heap-size '[ _ ] ] bi
] 1 define-partial-eval

! Eliminates a few redundant checks here and there
\ both-fixnums? [
    in-d>> first2 [ value-info class>> ] bi@ {
        { [ 2dup [ fixnum classes-intersect? not ] either? ] [ [ 2drop f ] ] }
        { [ 2dup [ fixnum class<= ] both? ] [ [ 2drop t ] ] }
        { [ dup fixnum class<= ] [ [ drop fixnum? ] ] }
        { [ over fixnum class<= ] [ [ nip fixnum? ] ] }
        [ f ]
    } cond 2nip
] "custom-inlining" set-word-prop
