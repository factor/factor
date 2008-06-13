USING: arrays kernel sequences sequences.lib math math.functions math.ranges
    tools.test strings ;
IN: sequences.lib.tests

[ 50 ] [ 100 [1,b] [ even? ] count ] unit-test
[ 50 ] [ 100 [1,b] [ odd? ] count ] unit-test
[ 328350 ] [ 100 [ sq ] sigma ] unit-test

[ 1 2 { 3 4 } [ + + drop ] 2 each-withn  ] must-infer
{ 13 } [ 1 2 { 3 4 } [ + + ] 2 each-withn + ] unit-test

[ 1 2 { 3 4 } [ + + ] 2 map-withn ] must-infer
{ { 6 7 } } [ 1 2 { 3 4 } [ + + ] 2 map-withn ] unit-test
{ { 16 17 18 19 20 } } [ 1 2 3 4 { 6 7 8 9 10 } [ + + + + ] 4 map-withn ] unit-test
[ { 910 911 912 } ] [ 10 900 3 [ + + ] map-with2 ] unit-test

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

[ 2 ] [ V{ 10 20 30 } [ delete-random drop ] keep length ] unit-test
[ V{ } [ delete-random drop ] keep length ] must-fail

[ { 1 9 25 } ] [ { 1 3 5 6 } [ sq ] [ even? ] map-until ] unit-test
[ { 2 4 } ] [ { 2 4 1 3 } [ even? ] take-while ] unit-test

[ { { 0 0 } { 1 0 } { 0 1 } { 1 1 } } ] [ 2 2 exact-strings ] unit-test
[ t ] [ "ab" 4 strings [ >string ] map "abab" swap member? ] unit-test
[ { { } { 1 } { 2 } { 1 2 } } ] [ { 1 2 } power-set ] unit-test

[ f ] [ { } ?first ] unit-test
[ f ] [ { } ?fourth ] unit-test
[ 1 ] [ { 1 2 3 } ?first ] unit-test
[ 2 ] [ { 1 2 3 } ?second ] unit-test
[ 3 ] [ { 1 2 3 } ?third ] unit-test
[ f ] [ { 1 2 3 } ?fourth ] unit-test

[ 50 ] [ 100 [1,b] [ even? ] count ] unit-test
[ 50 ] [ 100 [1,b] [ odd? ] count ] unit-test
[ 328350 ] [ 100 [ sq ] sigma ] unit-test

[ 1 2 { 3 4 } [ + + ] 2 map-withn ] must-infer
{ { 6 7 } } [ 1 2 { 3 4 } [ + + ] 2 map-withn ] unit-test
{ { 16 17 18 19 20 } } [ 1 2 3 4 { 6 7 8 9 10 } [ + + + + ] 4 map-withn ] unit-test
[ 1 2 { 3 4 } [ + + drop ] 2 each-withn  ] must-infer
{ 13 } [ 1 2 { 3 4 } [ + + ] 2 each-withn + ] unit-test
[ { 910 911 912 } ] [ 10 900 3 [ + + ] map-with2 ] unit-test

[ 1 2 3 4 ] [ { 1 2 3 4 } 4 firstn ] unit-test

[ ] [ { } 0 firstn ] unit-test
[ "a" ] [ { "a" } 1 firstn ] unit-test

[ "empty" ] [ { } [ "not empty" ] [ "empty" ] if-seq ] unit-test
[ { 1 } "not empty" ] [ { 1 } [ "not empty" ] [ "empty" ] if-seq ] unit-test

[ "empty" ] [ { } [ "empty" ] [ "not empty" ] if-empty ] unit-test
[ { 1 } "not empty" ] [ { 1 } [ "empty" ] [ "not empty" ] if-empty ] unit-test
