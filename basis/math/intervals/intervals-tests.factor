USING: accessors combinators fry kernel literals math math.intervals
math.intervals.private math.order math.statistics random sequences
sequences.deep tools.test vocabs ;
IN: math.intervals.tests

{ empty-interval } [ 2 2 (a,b) ] unit-test

{ empty-interval } [ 2 2.0 (a,b) ] unit-test

{ empty-interval } [ 2 2 [a,b) ] unit-test

{ empty-interval } [ 2 2 (a,b] ] unit-test

{ empty-interval } [ 3 2 [a,b] ] unit-test

{ T{ interval f { 1 t } { 2 t } } } [ 1 2 [a,b] ] unit-test

{ T{ interval f { 1 t } { 2 f } } } [ 1 2 [a,b) ] unit-test

{ T{ interval f { 1 f } { 2 f } } } [ 1 2 (a,b) ] unit-test

{ T{ interval f { 1 f } { 2 t } } } [ 1 2 (a,b] ] unit-test

{ T{ interval f { 1 t } { 1 t } } } [ 1 [a,a] ] unit-test

{ T{ interval f { 0 t } { 42 t } } } [ 42 [0,b] ] unit-test

{ T{ interval f { 0 t } { 42 f } } } [ 42 [0,b) ] unit-test

! Not sure how to handle NaNs yet...
! [ 1 0/0. [a,b] ] must-fail
! [ 0/0. 1 [a,b] ] must-fail

{ t } [ { 3 t } { 3 f } endpoint< ] unit-test
{ t } [ { 2 f } { 3 f } endpoint< ] unit-test
{ f } [ { 3 f } { 3 t } endpoint< ] unit-test
{ t } [ { 4 f } { 3 t } endpoint> ] unit-test
{ f } [ { 3 f } { 3 t } endpoint> ] unit-test

{ empty-interval } [ 1 2 [a,b] empty-interval interval+ ] unit-test

{ empty-interval } [ empty-interval 1 2 [a,b] interval+ ] unit-test

{ t } [
    1 2 [a,b] -3 3 [a,b] interval+ -2 5 [a,b] =
] unit-test

{ t } [
    1 2 [a,b] -3 3 (a,b) interval+ -2 5 (a,b) =
] unit-test

{ empty-interval } [ 1 2 [a,b] empty-interval interval- ] unit-test

{ empty-interval } [ empty-interval 1 2 [a,b] interval- ] unit-test

{ t } [
    1 2 [a,b] 0 1 [a,b] interval- 0 2 [a,b] =
] unit-test

{ empty-interval } [ 1 2 [a,b] empty-interval interval* ] unit-test

{ empty-interval } [ empty-interval 1 2 [a,b] interval* ] unit-test

{ t } [
    1 2 [a,b] 0 4 [a,b] interval* 0 8 [a,b] =
] unit-test

{ t } [
    1 2 [a,b] -4 4 [a,b] interval* -8 8 [a,b] =
] unit-test

{ t } [
    1 2 [a,b] -0.5 0.5 [a,b] interval* -1.0 1.0 [a,b] =
] unit-test

{ t } [
    1 2 [a,b] -0.5 0.5 (a,b] interval* -1.0 1.0 (a,b] =
] unit-test

{ t } [
    -1 1 [a,b] -1 1 (a,b] interval* -1 1 [a,b] =
] unit-test

{ t } [ 1 2 [a,b] dup empty-interval interval-union = ] unit-test

{ t } [ 1 2 [a,b] empty-interval over interval-union = ] unit-test

{ t } [
    0 1 (a,b) 0 1 [a,b] interval-union 0 1 [a,b] =
] unit-test

{ t } [
    0 1 (a,b) 1 2 [a,b] interval-union 0 2 (a,b] =
] unit-test

{ t } [
    0 1 (a,b) 0 1 [a,b] interval-intersect 0 1 (a,b) =
] unit-test

{ empty-interval } [ 0 5 [a,b] -1 [a,a] interval-intersect ] unit-test

{ empty-interval } [ 0 5 (a,b] 0 [a,a] interval-intersect ] unit-test

{ empty-interval } [ empty-interval -1 [a,a] interval-intersect ] unit-test

{ empty-interval } [ 0 5 (a,b] empty-interval interval-intersect ] unit-test

{ t } [
    0 1 (a,b) full-interval interval-intersect 0 1 (a,b) =
] unit-test

{ t } [
    empty-interval empty-interval interval-subset?
] unit-test

{ t } [
    empty-interval 0 1 [a,b] interval-subset?
] unit-test

{ t } [
    0 1 (a,b) 0 1 [a,b] interval-subset?
] unit-test

{ t } [
    full-interval -1/0. 1/0. [a,b] interval-subset?
] unit-test

{ t } [
    -1/0. 1/0. [a,b] full-interval interval-subset?
] unit-test

{ f } [
    full-interval 0 1/0. [a,b] interval-subset?
] unit-test

{ t } [
    0 1/0. [a,b] full-interval interval-subset?
] unit-test

{ f } [
    0 0 1 (a,b) interval-contains?
] unit-test

{ t } [
    0.5 0 1 (a,b) interval-contains?
] unit-test

{ f } [
    1 0 1 (a,b) interval-contains?
] unit-test

{ empty-interval } [ -1 1 (a,b) empty-interval interval/ ] unit-test

{ t } [ 0 0 331 [a,b) -1775 -953 (a,b) interval/ interval-contains? ] unit-test

{ t } [ -1 1 (a,b) -1 1 (a,b) interval/ [-inf,inf] = ] unit-test

{ t } [ -1 1 (a,b) 0 1 (a,b) interval/ [-inf,inf] = ] unit-test

"math.ratios.private" lookup-vocab [
    [ t ] [
        -1 1 (a,b) 0.5 1 (a,b) interval/ -2.0 2.0 (a,b) =
    ] unit-test
] when

{ f } [ empty-interval interval-singleton? ] unit-test

{ t } [ 1 [a,a] interval-singleton? ] unit-test

{ f } [ 1 1 [a,b) interval-singleton? ] unit-test

{ f } [ 1 3 [a,b) interval-singleton? ] unit-test

{ f } [ 1 1 (a,b) interval-singleton? ] unit-test

{ 2 } [ 1 3 [a,b) interval-length ] unit-test

{ 0 } [ empty-interval interval-length ] unit-test

{ t } [ 0 5 [a,b] 5 [a,a] interval<= ] unit-test

{ incomparable } [ empty-interval 5 [a,a] interval< ] unit-test

{ incomparable } [ 5 [a,a] empty-interval interval< ] unit-test

{ incomparable } [ 0 5 [a,b] 5 [a,a] interval< ] unit-test

{ t } [ 0 5 [a,b) 5 [a,a] interval< ] unit-test

{ f } [ 0 5 [a,b] -1 [a,a] interval< ] unit-test

{ incomparable } [ 0 5 [a,b] 1 [a,a] interval< ] unit-test

{ t } [ -1 1 (a,b) -1 [a,a] interval> ] unit-test

{ t } [ -1 1 (a,b) -1 [a,a] interval>= ] unit-test

{ f } [ -1 1 (a,b) -1 [a,a] interval< ] unit-test

{ f } [ -1 1 (a,b) -1 [a,a] interval<= ] unit-test

{ t } [ -1 1 (a,b] 1 [a,a] interval<= ] unit-test

{ t } [ -1 1 (a,b] 1 2 [a,b] interval<= ] unit-test

{ incomparable } [ -1 1 (a,b] empty-interval interval>= ] unit-test

{ incomparable } [ empty-interval -1 1 (a,b] interval>= ] unit-test

{ incomparable } [ -1 1 (a,b] 1 2 [a,b] interval>= ] unit-test

{ incomparable } [ -1 1 (a,b] 1 2 [a,b] interval> ] unit-test

{ t } [ -1 1 (a,b] 1 2 (a,b] interval<= ] unit-test

{ f } [ 0 10 [a,b] 0 [a,a] interval< ] unit-test

{ f } [ 0 10 [a,b] 0.0 [a,a] interval< ] unit-test

{ f } [ 0.0 10 [a,b] 0 [a,a] interval< ] unit-test

{ f } [ 0 10 [a,b] 10 [a,a] interval> ] unit-test

{ incomparable } [ 0 [a,a] 0 10 [a,b] interval< ] unit-test

{ incomparable } [ 10 [a,a] 0 10 [a,b] interval> ] unit-test

{ t } [ 0 [a,a] 0 10 [a,b] interval<= ] unit-test

{ incomparable } [ 0 [a,a] 0 10 [a,b] interval>= ] unit-test

{ t } [ 0 10 [a,b] 0 [a,a] interval>= ] unit-test

{ t } [
    418
    418 423 [a,b)
    79 893 (a,b]
    interval-max
    interval-contains?
] unit-test

{ t } [ full-interval 10 10 [a,b] interval-max 10 1/0. [a,b] = ] unit-test

{ t } [ full-interval 10 10 [a,b] interval-min -1/0. 10 [a,b] = ] unit-test

{ t } [ 1 100 [a,b] -1 1 [a,b] interval/i [-inf,inf] = ] unit-test

! Accuracy of interval-mod
{ t } [ full-interval 40 40 [a,b] interval-mod -40 40 (a,b) interval-subset?
] unit-test

! Interval random tester
: random-element ( interval -- n )
    dup full-interval eq? [
        drop 32 random-bits 31 2^ -
    ] [
        [ ] [ from>> first ] [ to>> first ] tri over - random +
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

: unary-ops ( -- alist )
    {
        { bitnot interval-bitnot }
        { abs interval-abs }
        { 2/ interval-2/ }
        { neg interval-neg }
    }
    "math.ratios.private" lookup-vocab [
        { recip interval-recip } suffix
    ] when ;

: unary-test ( op -- ? )
    [ random-interval ] dip
    0 pick interval-contains? over first \ recip eq? and [
        2drop t
    ] [
        [ [ random-element ] dip first execute( a -- b ) ] 2keep
        second execute( a -- b ) interval-contains?
    ] if ;

unary-ops [
    [ [ t ] ] dip '[ 8000 [ drop _ unary-test ] all-integers? ] unit-test
] each

: binary-ops ( -- alist )
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
        { min interval-min }
        { max interval-max }
    }
    "math.ratios.private" lookup-vocab [
        { / interval/ } suffix
    ] when ;

: binary-test ( op -- ? )
    [ random-interval random-interval ] dip
    0 pick interval-contains? over first { / /i mod rem } member? and [
        3drop t
    ] [
        [ [ [ random-element ] bi@ ] dip first execute( a b -- c ) ] 3keep
        second execute( a b -- c ) interval-contains?
    ] if ;

binary-ops [
    [ [ t ] ] dip '[ 8000 <iota> [ drop _ binary-test ] all? ] unit-test
] each

: comparison-ops ( -- alist )
    {
        { < interval< }
        { <= interval<= }
        { > interval> }
        { >= interval>= }
    } ;

: comparison-test ( op -- ? )
    [ random-interval random-interval ] dip
    [ [ [ random-element ] bi@ ] dip first execute( a b -- ? ) ] 3keep
    second execute( a b -- ? ) dup incomparable eq? [ 2drop t ] [ = ] if ;

comparison-ops [
    [ [ t ] ] dip '[ 8000 <iota> [ drop _ comparison-test ] all? ] unit-test
] each

{ t } [ -10 10 [a,b] 0 100 [a,b] assume> 0 10 (a,b] = ] unit-test

{ t } [ -10 10 [a,b] 0 100 [a,b] assume>= 0 10 [a,b] = ] unit-test

{ t } [ -10 10 [a,b] 0 100 [a,b] assume< -10 10 [a,b] = ] unit-test

{ t } [ -10 10 [a,b] -100 0 [a,b] assume< -10 0 [a,b) = ] unit-test

{ t } [ -10 10 [a,b] -100 0 [a,b] assume<= -10 0 [a,b] = ] unit-test

{ t } [ -10 10 [a,b] 0 100 [a,b] assume<= -10 10 [a,b] = ] unit-test

{ t } [ -10 10 [a,b] interval-abs 0 10 [a,b] = ] unit-test

{ t } [ full-interval interval-abs [0,inf] = ] unit-test

{ t } [ [0,inf] interval-abs [0,inf] = ] unit-test

{ t } [ empty-interval interval-abs empty-interval = ] unit-test

{ t } [ [0,inf] interval-sq [0,inf] = ] unit-test

! Test that commutative interval ops really are
: random-interval-or-empty ( -- obj )
    10 random 0 = [ empty-interval ] [ random-interval ] if ;

: commutative-ops ( -- seq )
    {
        interval+ interval*
        interval-bitor interval-bitand interval-bitxor
        interval-max interval-min
    } ;

commutative-ops [
    [ [ t ] ] dip '[
        8000 <iota> [
            drop
            random-interval-or-empty random-interval-or-empty _
            [ execute ] [ swapd execute ] 3bi =
        ] all?
    ] unit-test
] each

! Test singleton behavior
{ f } [ full-interval interval-nonnegative? ] unit-test

{ t } [ empty-interval interval-nonnegative? ] unit-test

{ t } [ full-interval interval-zero? ] unit-test

{ f } [ empty-interval interval-zero? ] unit-test

{ f f } [ -1/0. 1/0. [ empty-interval interval-contains? ] bi@ ] unit-test

{ t t } [ -1/0. 1/0. [ full-interval interval-contains? ] bi@ ] unit-test

! Interval bitand
${ 0 0xaf [a,b] } [ 0 0xff [a,b] 0 0xaf [a,b] interval-bitand ] unit-test
${ -0x100 -10 [a,b] } [ -0xff -1 [a,b] -0xaf -10 [a,b] interval-bitand ] unit-test
${ -0x100 10 [a,b] } [ -0xff 1 [a,b] -0xaf 10 [a,b] interval-bitand ] unit-test
${ 0 0xff [a,b] } [ -0xff -1 [a,b] 0 0xff [a,b] interval-bitand ] unit-test

! Interval bitor
{ 1/0. } [ 1/0. bit-weight ] unit-test
{ 1/0. } [ -1/0. bit-weight ] unit-test

{ t } [
    16 <iota> dup [ bitor ] cartesian-map flatten
    [ 0 15 [a,b] interval-contains? ] all?
] unit-test

${ 0 255 [a,b] } [ 0 255 [a,b] dup interval-bitor ] unit-test
${ 0 511 [a,b] } [ 0 256 [a,b] dup interval-bitor ] unit-test

${ -128 127 [a,b] } [ -128 127 [a,b] dup interval-bitor ] unit-test
${ -256 255 [a,b] } [ -128 128 [a,b] dup interval-bitor ] unit-test

{ full-interval } [ full-interval -128 127 [a,b] interval-bitor ] unit-test
${ 0 [a,inf] } [ 0 [a,inf] dup interval-bitor ] unit-test
{ full-interval } [ 0 [-inf,b] dup interval-bitor ] unit-test
${ 4 [a,inf] } [ 4 [a,inf] 3 [a,inf] interval-bitor ] unit-test

! Interval bitxor
${ 0 255 [a,b] } [ 0 255 [a,b] dup interval-bitxor ] unit-test
${ 0 511 [a,b] } [ 0 256 [a,b] dup interval-bitxor ] unit-test

${ -128 127 [a,b] } [ -128 127 [a,b] dup interval-bitxor ] unit-test
${ -256 255 [a,b] } [ -128 128 [a,b] dup interval-bitxor ] unit-test
${ 0 127 [a,b] } [ -128 -1 [a,b] dup interval-bitxor ] unit-test

{ full-interval } [ full-interval -128 127 [a,b] interval-bitxor ] unit-test
${ 0 [a,inf] } [ 0 [a,inf] dup interval-bitxor ] unit-test
${ 0 [a,inf] } [ -1 [-inf,b] dup interval-bitxor ] unit-test
${ 0 [a,inf] } [ 4 [a,inf] 3 [a,inf] interval-bitxor ] unit-test
{ full-interval } [ 4 [a,inf] -3 [a,inf] interval-bitxor ] unit-test
