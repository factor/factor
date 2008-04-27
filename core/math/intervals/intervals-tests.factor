USING: math.intervals kernel sequences words math math.order
arrays prettyprint tools.test random vocabs combinators ;
IN: math.intervals.tests

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

[ t ] [
    1 2 [a,b] -3 3 [a,b] interval+ -2 5 [a,b] =
] unit-test

[ t ] [
    1 2 [a,b] -3 3 (a,b) interval+ -2 5 (a,b) =
] unit-test

[ t ] [
    1 2 [a,b] 0 1 [a,b] interval- 0 2 [a,b] =
] unit-test

[ t ] [
    1 2 [a,b] 0 4 [a,b] interval* 0 8 [a,b] =
] unit-test

[ t ] [
    1 2 [a,b] -4 4 [a,b] interval* -8 8 [a,b] =
] unit-test

[ t ] [
    1 2 [a,b] -0.5 0.5 [a,b] interval* -1 1 [a,b] =
] unit-test

[ t ] [
    1 2 [a,b] -0.5 0.5 (a,b] interval* -1 1 (a,b] =
] unit-test

[ t ] [
    -1 1 [a,b] -1 1 (a,b] interval* -1 1 [a,b] =
] unit-test

[ t ] [
    0 1 (a,b) 0 1 [a,b] interval-union 0 1 [a,b] =
] unit-test

[ t ] [
    0 1 (a,b) 1 2 [a,b] interval-union 0 2 (a,b] =
] unit-test

[ f ] [ 0 1 (a,b) f interval-union ] unit-test

[ t ] [
    0 1 (a,b) 0 1 [a,b] interval-intersect 0 1 (a,b) =
] unit-test

[ f ] [ 0 5 [a,b] -1 [a,a] interval-intersect ] unit-test

[ f ] [ 0 5 (a,b] 0 [a,a] interval-intersect ] unit-test

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

[ f ] [ -1 1 (a,b) -1 1 (a,b) interval/ ] unit-test

[ f ] [ -1 1 (a,b) 0 1 (a,b) interval/ ] unit-test

"math.ratios.private" vocab [
    [ t ] [
        -1 1 (a,b) 0.5 1 (a,b) interval/ -2 2 (a,b) =
    ] unit-test
] when

[ t ] [ 1 [a,a] interval-singleton? ] unit-test

[ f ] [ 1 1 [a,b) interval-singleton? ] unit-test

[ f ] [ 1 3 [a,b) interval-singleton? ] unit-test

[ f ] [ 1 1 (a,b) interval-singleton? ] unit-test

[ 2 ] [ 1 3 [a,b) interval-length ] unit-test

[ 0 ] [ f interval-length ] unit-test

[ t ] [ 0 5 [a,b] 5 [a,a] interval<= ] unit-test

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

[ f ] [ 1 100 [a,b] -1 1 [a,b] interval/i ] unit-test

! Interval random tester
: random-element ( interval -- n )
    dup interval-to first over interval-from first tuck - random +
    2dup swap interval-contains? [
        nip
    ] [
        drop random-element
    ] if ;

: random-interval ( -- interval )
    1000 random dup 2 1000 random + +
    1 random zero? [ [ neg ] bi@ swap ] when
    4 random {
        { 0 [ [a,b] ] }
        { 1 [ [a,b) ] }
        { 2 [ (a,b) ] }
        { 3 [ (a,b] ] }
    } case ;

: random-op
    {
        { + interval+ }
        { - interval- }
        { * interval* }
        { /i interval/i }
        { shift interval-shift }
        { min interval-min }
        { max interval-max }
    }
    "math.ratios.private" vocab [
        { / interval/ } suffix
    ] when
    random ;

: interval-test
    random-interval random-interval random-op ! 3dup . . .
    0 pick interval-contains? over first { / /i } member? and [
        3drop t
    ] [
        [ >r [ random-element ] bi@ ! 2dup . .
        r> first execute ] 3keep
        second execute interval-contains?
    ] if ;

[ t ] [ 40000 [ drop interval-test ] all? ] unit-test

: random-comparison
    {
        { < interval< }
        { <= interval<= }
        { > interval> }
        { >= interval>= }
    } random ;

: comparison-test
    random-interval random-interval random-comparison
    [ >r [ random-element ] bi@ r> first execute ] 3keep
    second execute dup incomparable eq? [
        2drop t
    ] [
        =
    ] if ;

[ t ] [ 40000 [ drop comparison-test ] all? ] unit-test
