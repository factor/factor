IN: splitting.monotonic
USING: tools.test math arrays kernel sequences ;

[ { { 1 } { -1 5 } { 2 4 } } ]
[ { 1 -1 5 2 4 } [ < ] monotonic-split [ >array ] map ] unit-test
[ { { 1 1 1 1 } { 2 2 } { 3 } { 4 } { 5 } { 6 6 6 } } ]
[ { 1 1 1 1 2 2 3 4 5 6 6 6 } [ = ] monotonic-split [ >array ] map ] unit-test

