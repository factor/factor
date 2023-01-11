USING: grouping kernel math math.order random sequences sets
sorting tools.test vocabs ;

{ { } } [ { } natural-sort ] unit-test

{ { 270000000 270000001 } }
[ T{ slice f 270000000 270000002 T{ iota f 270000002 } } natural-sort ]
unit-test

{ t } [
    100 [
        drop
        100 [ 20 random [ 1000 random ] replicate ] replicate
        dup natural-sort
        [ set= ] [ nip [ before=? ] monotonic? ] 2bi and
    ] all-integers?
] unit-test

[ { 1 2 } [ 2drop 1 ] sort ] must-not-fail

! Is it a stable sort?
{ t } [ { { 1 "a" } { 1 "b" } { 1 "c" } } dup sort-keys = ] unit-test

{ { { 1 "a" } { 1 "b" } { 1 "c" } { 1 "e" } { 2 "d" } } }
[ { { 1 "a" } { 1 "b" } { 1 "c" } { 2 "d" } { 1 "e" } } sort-keys ] unit-test

[ all-words natural-sort ] must-not-fail

{ +gt+ } [ "lady" "bug" { [ length ] [ first ] } compare-with ] unit-test
{ +lt+ } [ "bug" "lady" { [ length ] [ first ] } compare-with ] unit-test
{ +eq+ } [ "bat" "bat" { [ length ] [ first ] } compare-with ] unit-test
{ +lt+ } [ "bat" "cat" { [ length ] [ first ] } compare-with ] unit-test
{ +gt+ } [ "fat" "cat" { [ length ] [ first ] } compare-with ] unit-test
