USING: math math.ranges sequences sets tools.test arrays ;
IN: math.ranges.tests

[ { } ] [ 1 1 (a,b) >array ] unit-test
[ { } ] [ 1 1 (a,b] >array ] unit-test
[ { } ] [ 1 1 [a,b) >array ] unit-test
[ { 1 } ] [ 1 1 [a,b] >array ] unit-test

[ { }  ] [ 1 2 (a,b) >array ] unit-test
[ { 2 } ] [ 1 2 (a,b] >array ] unit-test
[ { 1 } ] [ 1 2 [a,b) >array ] unit-test
[ { 1 2 } ] [ 1 2 [a,b] >array ] unit-test

[ { } ] [ 2 1 (a,b) >array ] unit-test
[ { 1 } ] [ 2 1 (a,b] >array ] unit-test
[ { 2 } ] [ 2 1 [a,b) >array ] unit-test
[ { 2 1 } ] [ 2 1 [a,b] >array ] unit-test

[ { 1 2 3 4 5 } ] [ 1 5 1 <range> >array ] unit-test
[ { 5 4 3 2 1 } ] [ 5 1 -1 <range> >array ] unit-test

[ { 0 1/3 2/3 1 } ] [ 0 1 1/3 <range> >array ] unit-test
[ { 0 1/3 2/3 1 } ] [ 1 0 -1/3 <range> >array reverse ] unit-test

[ 100 ] [
    1 100 [a,b] [ 2^ [1,b] ] map prune length
] unit-test
