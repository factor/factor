USING: math.intervals kernel sequences words math arrays
prettyprint tools.test random ;
IN: temporary

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

[ t ] [
    -1 1 (a,b) 0.5 1 (a,b) interval/ -2 2 (a,b) =
] unit-test

[ t ] [ 0 5 [a,b] 5 interval<= ] unit-test

[ incomparable ] [ 0 5 [a,b] 5 interval< ] unit-test

[ t ] [ 0 5 [a,b) 5 interval< ] unit-test

[ f ] [ 0 5 [a,b] -1 interval< ] unit-test

[ incomparable ] [ 0 5 [a,b] 1 interval< ] unit-test

[ t ] [ -1 1 (a,b) -1 interval> ] unit-test

[ t ] [ -1 1 (a,b) -1 interval>= ] unit-test

[ f ] [ -1 1 (a,b) -1 interval< ] unit-test

[ f ] [ -1 1 (a,b) -1 interval<= ] unit-test

[ t ] [ -1 1 (a,b] 1 interval<= ] unit-test

! Interval random tester
: random-element ( interval -- n )
    dup interval-to first swap interval-from first tuck -
    random + ;

: random-interval ( -- interval )
    1000 random dup 1 1000 random + + [a,b] ;

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
        { / interval/ } add
    ] when
    random ;

: interval-test
    random-interval random-interval random-op
    0 pick interval-contains? over first { / /i } member? and [
        3drop t
    ] [
        [ >r [ random-element ] 2apply r> first execute ] 3keep
        second execute interval-contains?
    ] if ;

[ t ] [ 1000 [ drop interval-test ] all? ] unit-test
