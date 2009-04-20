USING: math.intervals kernel sequences words math math.order
arrays prettyprint tools.test random vocabs combinators
accessors math.constants ;
IN: math.intervals.tests

[ empty-interval ] [ 2 2 (a,b) ] unit-test

[ empty-interval ] [ 2 2 [a,b) ] unit-test

[ empty-interval ] [ 2 2 (a,b] ] unit-test

[ empty-interval ] [ 3 2 [a,b] ] unit-test

[ T{ interval f { 1 t } { 2 t } } ] [ 1 2 [a,b] ] unit-test

[ T{ interval f { 1 t } { 2 f } } ] [ 1 2 [a,b) ] unit-test

[ T{ interval f { 1 f } { 2 f } } ] [ 1 2 (a,b) ] unit-test

[ T{ interval f { 1 f } { 2 t } } ] [ 1 2 (a,b] ] unit-test

[ T{ interval f { 1 t } { 1 t } } ] [ 1 [a,a] ] unit-test

[ t ] [ { 3 t } { 3 f } endpoint< ] unit-test
[ t ] [ { 2 f } { 3 f } endpoint< ] unit-test
[ f ] [ { 3 f } { 3 t } endpoint< ] unit-test
[ t ] [ { 4 f } { 3 t } endpoint> ] unit-test
[ f ] [ { 3 f } { 3 t } endpoint> ] unit-test

[ empty-interval ] [ 1 2 [a,b] empty-interval interval+ ] unit-test

[ empty-interval ] [ empty-interval 1 2 [a,b] interval+ ] unit-test

[ t ] [
    1 2 [a,b] -3 3 [a,b] interval+ -2 5 [a,b] =
] unit-test

[ t ] [
    1 2 [a,b] -3 3 (a,b) interval+ -2 5 (a,b) =
] unit-test

[ empty-interval ] [ 1 2 [a,b] empty-interval interval- ] unit-test

[ empty-interval ] [ empty-interval 1 2 [a,b] interval- ] unit-test

[ t ] [
    1 2 [a,b] 0 1 [a,b] interval- 0 2 [a,b] =
] unit-test

[ empty-interval ] [ 1 2 [a,b] empty-interval interval* ] unit-test

[ empty-interval ] [ empty-interval 1 2 [a,b] interval* ] unit-test

[ t ] [
    1 2 [a,b] 0 4 [a,b] interval* 0 8 [a,b] =
] unit-test

[ t ] [
    1 2 [a,b] -4 4 [a,b] interval* -8 8 [a,b] =
] unit-test

[ t ] [
    1 2 [a,b] -0.5 0.5 [a,b] interval* -1.0 1.0 [a,b] =
] unit-test

[ t ] [
    1 2 [a,b] -0.5 0.5 (a,b] interval* -1.0 1.0 (a,b] =
] unit-test

[ t ] [
    -1 1 [a,b] -1 1 (a,b] interval* -1 1 [a,b] =
] unit-test

[ t ] [ 1 2 [a,b] dup empty-interval interval-union = ] unit-test

[ t ] [ empty-interval 1 2 [a,b] tuck interval-union = ] unit-test

[ t ] [
    0 1 (a,b) 0 1 [a,b] interval-union 0 1 [a,b] =
] unit-test

[ t ] [
    0 1 (a,b) 1 2 [a,b] interval-union 0 2 (a,b] =
] unit-test

[ t ] [
    0 1 (a,b) 0 1 [a,b] interval-intersect 0 1 (a,b) =
] unit-test

[ empty-interval ] [ 0 5 [a,b] -1 [a,a] interval-intersect ] unit-test

[ empty-interval ] [ 0 5 (a,b] 0 [a,a] interval-intersect ] unit-test

[ empty-interval ] [ empty-interval -1 [a,a] interval-intersect ] unit-test

[ empty-interval ] [ 0 5 (a,b] empty-interval interval-intersect ] unit-test

[ t ] [
    0 1 (a,b) full-interval interval-intersect 0 1 (a,b) =
] unit-test

[ t ] [
    empty-interval empty-interval interval-subset?
] unit-test

[ t ] [
    empty-interval 0 1 [a,b] interval-subset?
] unit-test

[ t ] [
    0 1 (a,b) 0 1 [a,b] interval-subset?
] unit-test

[ f ] [
    0 0 1 (a,b) interval-contains?
] unit-test

[ t ] [
    0.5 0 1 (a,b) interval-contains?
] unit-test

[ f ] [
    1 0 1 (a,b) interval-contains?
] unit-test

[ empty-interval ] [ -1 1 (a,b) empty-interval interval/ ] unit-test

[ t ] [ 0 0 331 [a,b) -1775 -953 (a,b) interval/ interval-contains? ] unit-test

[ t ] [ -1 1 (a,b) -1 1 (a,b) interval/ [-inf,inf] = ] unit-test

[ t ] [ -1 1 (a,b) 0 1 (a,b) interval/ [-inf,inf] = ] unit-test

"math.ratios.private" vocab [
    [ t ] [
        -1 1 (a,b) 0.5 1 (a,b) interval/ -2.0 2.0 (a,b) =
    ] unit-test
] when

[ f ] [ empty-interval interval-singleton? ] unit-test

[ t ] [ 1 [a,a] interval-singleton? ] unit-test

[ f ] [ 1 1 [a,b) interval-singleton? ] unit-test

[ f ] [ 1 3 [a,b) interval-singleton? ] unit-test

[ f ] [ 1 1 (a,b) interval-singleton? ] unit-test

[ 2 ] [ 1 3 [a,b) interval-length ] unit-test

[ 0 ] [ empty-interval interval-length ] unit-test

[ t ] [ 0 5 [a,b] 5 [a,a] interval<= ] unit-test

[ incomparable ] [ empty-interval 5 [a,a] interval< ] unit-test

[ incomparable ] [ 5 [a,a] empty-interval interval< ] unit-test

[ incomparable ] [ 0 5 [a,b] 5 [a,a] interval< ] unit-test

[ t ] [ 0 5 [a,b) 5 [a,a] interval< ] unit-test

[ f ] [ 0 5 [a,b] -1 [a,a] interval< ] unit-test

[ incomparable ] [ 0 5 [a,b] 1 [a,a] interval< ] unit-test

[ t ] [ -1 1 (a,b) -1 [a,a] interval> ] unit-test

[ t ] [ -1 1 (a,b) -1 [a,a] interval>= ] unit-test

[ f ] [ -1 1 (a,b) -1 [a,a] interval< ] unit-test

[ f ] [ -1 1 (a,b) -1 [a,a] interval<= ] unit-test

[ t ] [ -1 1 (a,b] 1 [a,a] interval<= ] unit-test

[ t ] [ -1 1 (a,b] 1 2 [a,b] interval<= ] unit-test

[ incomparable ] [ -1 1 (a,b] empty-interval interval>= ] unit-test

[ incomparable ] [ empty-interval -1 1 (a,b] interval>= ] unit-test

[ incomparable ] [ -1 1 (a,b] 1 2 [a,b] interval>= ] unit-test

[ incomparable ] [ -1 1 (a,b] 1 2 [a,b] interval> ] unit-test

[ t ] [ -1 1 (a,b] 1 2 (a,b] interval<= ] unit-test

[ f ] [ 0 10 [a,b] 0 [a,a] interval< ] unit-test

[ f ] [ 0 10 [a,b] 10 [a,a] interval> ] unit-test

[ incomparable ] [ 0 [a,a] 0 10 [a,b] interval< ] unit-test

[ incomparable ] [ 10 [a,a] 0 10 [a,b] interval> ] unit-test

[ t ] [ 0 [a,a] 0 10 [a,b] interval<= ] unit-test

[ incomparable ] [ 0 [a,a] 0 10 [a,b] interval>= ] unit-test

[ t ] [ 0 10 [a,b] 0 [a,a] interval>= ] unit-test

[ t ] [
    418
    418 423 [a,b)
    79 893 (a,b]
    interval-max
    interval-contains?
] unit-test

[ t ] [ 1 100 [a,b] -1 1 [a,b] interval/i [-inf,inf] = ] unit-test

! Interval random tester
: random-element ( interval -- n )
    dup full-interval eq? [
        drop 32 random-bits 31 2^ -
    ] [
        dup to>> first over from>> first tuck - random +
        2dup swap interval-contains? [
            nip
        ] [
            drop random-element
        ] if
    ] if ;

: random-interval ( -- interval )
    10 random 0 = [ full-interval ] [
        2000 random 1000 - dup 2 1000 random + +
        1 random zero? [ [ neg ] bi@ swap ] when
        4 random {
            { 0 [ [a,b] ] }
            { 1 [ [a,b) ] }
            { 2 [ (a,b) ] }
            { 3 [ (a,b] ] }
        } case
    ] if ;

: random-unary-op ( -- pair )
    {
        { bitnot interval-bitnot }
        { abs interval-abs }
        { 2/ interval-2/ }
        { 1+ interval-1+ }
        { 1- interval-1- }
        { neg interval-neg }
    }
    "math.ratios.private" vocab [
        { recip interval-recip } suffix
    ] when
    random ;

: unary-test ( -- ? )
    random-interval random-unary-op ! 2dup . .
    0 pick interval-contains? over first \ recip eq? and [
        2drop t
    ] [
        [ [ random-element ] dip first execute( a -- b ) ] 2keep
        second execute( a -- b ) interval-contains?
    ] if ;

[ t ] [ 80000 iota [ drop unary-test ] all? ] unit-test

: random-binary-op ( -- pair )
    {
        { + interval+ }
        { - interval- }
        { * interval* }
        { /i interval/i }
        { mod interval-mod }
        { rem interval-rem }
        { bitand interval-bitand }
        { bitor interval-bitor }
        { bitxor interval-bitxor }
        ! { shift interval-shift }
        { min interval-min }
        { max interval-max }
    }
    "math.ratios.private" vocab [
        { / interval/ } suffix
    ] when
    random ;

: binary-test ( -- ? )
    random-interval random-interval random-binary-op ! 3dup . . .
    0 pick interval-contains? over first { / /i mod rem } member? and [
        3drop t
    ] [
        [ [ [ random-element ] bi@ ] dip first execute( a b -- c ) ] 3keep
        second execute( a b -- c ) interval-contains?
    ] if ;

[ t ] [ 80000 iota [ drop binary-test ] all? ] unit-test

: random-comparison ( -- pair )
    {
        { < interval< }
        { <= interval<= }
        { > interval> }
        { >= interval>= }
    } random ;

: comparison-test ( -- ? )
    random-interval random-interval random-comparison
    [ [ [ random-element ] bi@ ] dip first execute ] 3keep
    second execute dup incomparable eq? [ 2drop t ] [ = ] if ;

[ t ] [ 40000 iota [ drop comparison-test ] all? ] unit-test

[ t ] [ -10 10 [a,b] 0 100 [a,b] assume> 0 10 (a,b] = ] unit-test

[ t ] [ -10 10 [a,b] 0 100 [a,b] assume>= 0 10 [a,b] = ] unit-test

[ t ] [ -10 10 [a,b] 0 100 [a,b] assume< -10 10 [a,b] = ] unit-test

[ t ] [ -10 10 [a,b] -100 0 [a,b] assume< -10 0 [a,b) = ] unit-test

[ t ] [ -10 10 [a,b] -100 0 [a,b] assume<= -10 0 [a,b] = ] unit-test

[ t ] [ -10 10 [a,b] 0 100 [a,b] assume<= -10 10 [a,b] = ] unit-test

[ t ] [ -10 10 [a,b] interval-abs 0 10 [a,b] = ] unit-test

! Test that commutative interval ops really are
: random-interval-or-empty ( -- obj )
    10 random 0 = [ empty-interval ] [ random-interval ] if ;

: random-commutative-op ( -- op )
    {
        interval+ interval*
        interval-bitor interval-bitand interval-bitxor
        interval-max interval-min
    } random ;

[ t ] [
    80000 iota [
        drop
        random-interval-or-empty random-interval-or-empty
        random-commutative-op
        [ execute ] [ swapd execute ] 3bi =
    ] all?
] unit-test
