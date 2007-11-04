USING: arrays kernel sequences sequences.lib math
math.functions tools.test ;

[ 4 ] [ { 1 2 } [ sq ] [ * ] map-reduce ] unit-test
[ 36 ] [ { 2 3 } [ sq ] [ * ] map-reduce ] unit-test

[ 10 ] [ { 1 2 3 4 } [ + ] reduce* ] unit-test
[ 24 ] [ { 1 2 3 4 } [ * ] reduce* ] unit-test

[ -4 ] [ 1 -4 [ abs ] higher ] unit-test
[ 1 ] [ 1 -4 [ abs ] lower ] unit-test

[ { 1 2 3 4 } ] [ { { 1 2 3 4 } { 1 2 3 } } longest ] unit-test
[ { 1 2 3 4 } ] [ { { 1 2 3 } { 1 2 3 4 } } longest ] unit-test

[ { 1 2 3 } ] [ { { 1 2 3 4 } { 1 2 3 } } shortest ] unit-test
[ { 1 2 3 } ] [ { { 1 2 3 } { 1 2 3 4 } } shortest ] unit-test

[ 3 ] [ 1 3 bigger ] unit-test
[ 1 ] [ 1 3 smaller ] unit-test

[ "abd" ] [ "abc" "abd" bigger ] unit-test
[ "abc" ] [ "abc" "abd" smaller ] unit-test

[ "abe" ] [ { "abc" "abd" "abe" } biggest ] unit-test
[ "abc" ] [ { "abc" "abd" "abe" } smallest ] unit-test

[ 1 3 ] [ { 1 2 3 } minmax ] unit-test
[ -11 -9 ] [ { -11 -10 -9 } minmax ] unit-test
[ -1/0. 1/0. ] [ { -1/0. 1/0. -11 -10 -9 } minmax ] unit-test

[ { { 1 } { -1 5 } { 2 4 } } ]
[ { 1 -1 5 2 4 } [ < ] monotonic-split [ >array ] map ] unit-test
[ { { 1 1 1 1 } { 2 2 } { 3 } { 4 } { 5 } { 6 6 6 } } ]
[ { 1 1 1 1 2 2 3 4 5 6 6 6 } [ = ] monotonic-split [ >array ] map ] unit-test
