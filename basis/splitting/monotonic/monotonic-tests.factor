IN: splitting.monotonic
USING: tools.test math arrays kernel sequences ;

{ { } } [ { } [ < ] monotonic-split ] unit-test
[ { { 1 } { -1 5 } { 2 4 } } ]
[ { 1 -1 5 2 4 } [ < ] monotonic-split [ >array ] map ] unit-test
[ { { 1 1 1 1 } { 2 2 } { 3 } { 4 } { 5 } { 6 6 6 } } ]
[ { 1 1 1 1 2 2 3 4 5 6 6 6 } [ = ] monotonic-split [ >array ] map ] unit-test

[ { } ]
[ { } [ = ] slice monotonic-slice ] unit-test

[ t ]
[ { 1 } [ = ] slice monotonic-slice [ slice? ] all? ] unit-test

[ { { 1 } } ]
[ { 1 } [ = ] slice monotonic-slice [ >array ] map ] unit-test

[ { 1 } [ = ] slice monotonic-slice ] must-infer

[ t ]
[ { 1 1 1 2 2 3 3 4 } [ = ] slice monotonic-slice [ slice? ] all? ] unit-test

[ { { 1 1 1 } { 2 2 } { 3 3 } { 4 } } ]
[ { 1 1 1 2 2 3 3 4 } [ = ] slice monotonic-slice [ >array ] map ] unit-test

[ { { 3 3 } } ]
[ { 3 3 } [ = ] slice monotonic-slice [ >array ] map ] unit-test

[
    {
        T{ upward-slice { from 0 } { to 3 } { seq { 1 2 3 2 1 } } }
        T{ downward-slice { from 2 } { to 5 } { seq { 1 2 3 2 1 } } }
    }
]
[ { 1 2 3 2 1 } trends ] unit-test

[
    {
        T{ upward-slice
            { from 0 }
            { to 3 }
            { seq { 1 2 3 3 2 1 } }
        }
        T{ stable-slice
            { from 2 }
            { to 4 }
            { seq { 1 2 3 3 2 1 } }
        }
        T{ downward-slice
            { from 3 }
            { to 6 }
            { seq { 1 2 3 3 2 1 } }
        }
    }
] [ { 1 2 3 3 2 1 } trends ] unit-test


[ { { 2 2 } { 3 3 3 3 } { 4 } { 5 } } ]
[
    { 2 2 3 3 3 3 4 5 }
    [ [ odd? ] same? ] slice monotonic-slice
    [ >array ] map
] unit-test

[
    { { 1 1 1 } { 2 2 2 2 } { 3 3 } }
] [
    { 1 1 1 2 2 2 2 3 3 }
    [ [ odd? ] same? ] slice monotonic-slice
    [ >array ] map
] unit-test
