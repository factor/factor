USING: math.ranges sequences tools.test arrays ;
IN: temporary

[ { } ] [ 1 1 (a,b) >array ] unit-test
[ { } ] [ 1 1 (a,b] >array ] unit-test
[ { } ] [ 1 1 [a,b) >array ] unit-test
[ { 1 } ] [ 1 1 [a,b] >array ] unit-test

[ { }  ] [ 1 2 (a,b) >array ] unit-test
[ { 2 } ] [ 1 2 (a,b] >array ] unit-test
[ { 1 } ] [ 1 2 [a,b) >array ] unit-test
[ { 1 2 } ] [ 1 2 [a,b] >array ] unit-test

[ { }  ] [ 2 1 (a,b) >array ] unit-test
[ { 1 } ] [ 2 1 (a,b] >array ] unit-test
[ { 2 } ] [ 2 1 [a,b) >array ] unit-test
[ { 2 1 } ] [ 2 1 [a,b] >array ] unit-test

[ { 1 2 3 4 5 } ] [ 1 5 1 <range> >array ] unit-test
[ { 5 4 3 2 1 } ] [ 5 1 -1 <range> >array ] unit-test

[ { 0 1/3 2/3 1 } ] [ 0 1 1/3 <range> >array ] unit-test
[ { 0 1/3 2/3 1 } ] [ 1 0 -1/3 <range> >array reverse ] unit-test

[ t ] [ 5 [0,b] range-increasing? ] unit-test
[ f ] [ 5 [0,b] range-decreasing? ] unit-test
[ f ] [ -5 [0,b] range-increasing? ] unit-test
[ t ] [ -5 [0,b] range-decreasing? ] unit-test
[ 0 ] [ 5 [0,b] range-min ] unit-test
[ 5 ] [ 5 [0,b] range-max ] unit-test
[ 3 ] [ 3 5 [0,b] clamp-to-range ] unit-test
[ 0 ] [ -1 5 [0,b] clamp-to-range ] unit-test
[ 5 ] [ 6 5 [0,b] clamp-to-range ] unit-test
[ { 0 1 2 3 4 } ] [ 5 sequence-index-range >array ] unit-test
