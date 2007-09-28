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
