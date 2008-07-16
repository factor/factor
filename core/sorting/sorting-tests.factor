USING: sorting sequences kernel math math.order random
tools.test vectors sets ;
IN: sorting.tests

[ { } ] [ { } natural-sort ] unit-test

[ { 270000000 270000001 } ]
[ T{ slice f 270000000 270000002 270000002 } natural-sort ]
unit-test

[ t ] [
    100 [
        drop
        100 [ 20 random [ 1000 random ] replicate ] replicate
        dup natural-sort
        [ set= ] [ nip [ before=? ] monotonic? ] 2bi and
    ] all?
] unit-test

[ ] [ { 1 2 } [ 2drop 1 ] sort drop ] unit-test
