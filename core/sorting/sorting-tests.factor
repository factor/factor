USING: sorting sequences kernel math random tools.test
vectors ;
IN: temporary

[ [ ] ] [ [ ] natural-sort ] unit-test

[ { 270000000 270000001 } ]
[ T{ slice f 270000000 270000002 270000002 } natural-sort ]
unit-test

[ t ] [
    100 [
        drop
        100 [ drop 20 random [ drop 1000 random ] map ] map natural-sort [ <=> 0 <= ] monotonic?
    ] all?
] unit-test

[ ] [ { 1 2 } [ 2drop 1 ] sort drop ] unit-test

[ 3 ] [ { 1 2 3 4 } midpoint ] unit-test

[ f ] [ 3 { } [ - ] binsearch ] unit-test
[ 0 ] [ 3 { 3 } [ - ] binsearch ] unit-test
[ 1 ] [ 2 { 1 2 3 } [ - ] binsearch ] unit-test
[ 3 ] [ 4 { 1 2 3 4 5 6 } [ - ] binsearch ] unit-test
[ 1 ] [ 3.5 { 1 2 3 4 5 6 7 8 } [ - ] binsearch ] unit-test
[ 3 ] [ 5.5 { 1 2 3 4 5 6 7 8 } [ - ] binsearch ] unit-test
[ 10 ] [ 10 20 >vector [ - ] binsearch ] unit-test
