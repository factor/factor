USING: grouping kernel math math.order random sequences sets
sorting tools.test vocabs ;

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

! Is it a stable sort?
{ t } [ { { 1 "a" } { 1 "b" } { 1 "c" } } dup sort-keys = ] unit-test

{ { { 1 "a" } { 1 "b" } { 1 "c" } { 1 "e" } { 2 "d" } } }
[ { { 1 "a" } { 1 "b" } { 1 "c" } { 2 "d" } { 1 "e" } } sort-keys ] unit-test

[ all-words sort ] must-not-fail
