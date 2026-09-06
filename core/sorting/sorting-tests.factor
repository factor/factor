USING: grouping kernel math math.order random sequences sets
sorting splitting tools.test unicode vocabs ;

{ { } } [ { } sort ] unit-test

{ { 270000000 270000001 } }
[ T{ slice f 270000000 270000002 T{ iota f 270000002 } } sort ]
unit-test

{ t } [
    100 [
        drop
        100 [ 20 random [ 1000 random ] replicate ] replicate
        dup sort
        [ set= ] [ nip [ before=? ] monotonic? ] 2bi and
    ] all-integers?
] unit-test

[ { 1 2 } [ 2drop 1 ] sort-with ] must-not-fail
{ { 1 2 3 4 5 6 } } [ { 5 2 6 1 4 3 } [ <=> ] sort-with ] unit-test
{ 3 { 1 2 3 4 5 6 } } [ 3 { 5 2 6 1 4 3 } [ pick 3 assert= <=> ] sort-with ] unit-test

! Is it a stable sort?
{ t } [ { { 1 "a" } { 1 "b" } { 1 "c" } } dup sort-keys = ] unit-test

{ { { 1 "a" } { 1 "b" } { 1 "c" } { 1 "e" } { 2 "d" } } }
[ { { 1 "a" } { 1 "b" } { 1 "c" } { 2 "d" } { 1 "e" } } sort-keys ] unit-test

[ all-words sort ] must-not-fail

IN: sorting.tests

! #2638: infer recursive key extractors inside a compiled sorting word.
: digit-order ( str -- str' )
    " " split [ [ digit? ] find nip ] sort-by " " join ;

: digit-order-comparator ( str -- str' )
    " " split [ [ [ digit? ] find nip ] bi@ <=> ] sort-with " " join ;

{ "Thi1s is2 3a T4est" } [ "is2 Thi1s T4est 3a" digit-order ] unit-test
{ "Thi1s is2 3a T4est" } [ "is2 Thi1s T4est 3a" digit-order-comparator ] unit-test
{ "Fo1r the2 g3ood 4of th5e pe6ople" }
[ "4of Fo1r pe6ople g3ood th5e the2" digit-order ] unit-test
{ "" } [ "" digit-order ] unit-test
