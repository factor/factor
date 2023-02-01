USING: unrolled-lists tools.test deques kernel sequences
random prettyprint grouping math ranges ;

{ 1 } [ <unrolled-list> 1 over push-front pop-front ] unit-test
{ 1 } [ <unrolled-list> 1 over push-front pop-back ] unit-test
{ 1 } [ <unrolled-list> 1 over push-back pop-front ] unit-test
{ 1 } [ <unrolled-list> 1 over push-back pop-back ] unit-test

{ 1 2 } [
    <unrolled-list> 1 over push-back 2 over push-back
    [ pop-front ] [ pop-front ] bi
] unit-test

{ 2 1 } [
    <unrolled-list> 1 over push-back 2 over push-back
    [ pop-back ] [ pop-back ] bi
] unit-test

{ 1 2 3 } [
    <unrolled-list>
    1 over push-back
    2 over push-back
    3 over push-back
    [ pop-front ] [ pop-front ] [ pop-front ] tri
] unit-test

{ 3 2 1 } [
    <unrolled-list>
    1 over push-back
    2 over push-back
    3 over push-back
    [ pop-back ] [ pop-back ] [ pop-back ] tri
] unit-test

{ { 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 } } [
    <unrolled-list>
    32 [ over push-front ] each-integer
    32 [ dup pop-back ] replicate
    nip
] unit-test

{ { 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 } } [
    <unrolled-list>
    32 [ over push-front ] each-integer
    32 [ dup pop-front ] replicate reverse
    nip
] unit-test

{ t } [
    <unrolled-list>
    1000 [ 1000 random ] replicate
    [ [ over push-front ] each ]
    [ length [ dup pop-back ] replicate ]
    [ ]
    tri
    =
    nip
] unit-test

{ t } [
    <unrolled-list>
    1000 [ 1000 random ] replicate
    [
        10 group [
            [ [ over push-front ] each ]
            [ length [ dup pop-back ] replicate ]
            bi
        ] map concat
    ] keep
    =
    nip
] unit-test

{ t } [ <unrolled-list> deque-empty? ] unit-test

{ t } [
    <unrolled-list>
    1 over push-front
    dup pop-front*
    deque-empty?
] unit-test

{ t } [
    <unrolled-list>
    1 over push-back
    dup pop-front*
    deque-empty?
] unit-test

{ t } [
    <unrolled-list>
    1 over push-front
    dup pop-back*
    deque-empty?
] unit-test

{ t } [
    <unrolled-list>
    1 over push-back
    dup pop-back*
    deque-empty?
] unit-test

{ t } [
    <unrolled-list>
    21 over push-front
    22 over push-front
    25 over push-front
    26 over push-front
    dup pop-back 21 assert=
    28 over push-front
    dup pop-back 22 assert=
    29 over push-front
    dup pop-back 25 assert=
    24 over push-front
    dup pop-back 26 assert=
    23 over push-front
    dup pop-back 28 assert=
    dup pop-back 29 assert=
    dup pop-back 24 assert=
    17 over push-front
    dup pop-back 23 assert=
    27 over push-front
    dup pop-back 17 assert=
    30 over push-front
    dup pop-back 27 assert=
    dup pop-back 30 assert=
    deque-empty?
] unit-test

! In relation to https://github.com/factor/factor/issues/2729
10 [| |
    <unrolled-list> :> l
    [
        33 200 [a..b] random dup
        l swap [1..b] [ over push-back ] each
        swap [ dup pop-front drop ] times
        dup pop-front swap pop-back
    ] [ empty-deque? ] must-fail-with
] times
