IN: temporary
USING: lists math sequences test vectors ;

[ [ 1 2 3 4 ] ] [ 1 5 <range> >list ] unit-test
[ 3 ] [ 1 4 <range> length ] unit-test
[ [ 4 3 2 1 ] ] [ 4 0 <range> >list ] unit-test
[ 2 ] [ 1 3 { 1 2 3 4 } <slice> length ] unit-test
[ [ 2 3 ] ] [ 1 3 { 1 2 3 4 } <slice> >list ] unit-test
[ { 4 5 } ] [ 2 { 1 2 3 4 5 } tail-slice* >vector ] unit-test
[ { 1 2 } { 3 4 } ] [ 2 { 1 2 3 4 } cut ] unit-test
[ { 1 2 } { 4 5 } ] [ 2 { 1 2 3 4 5 } cut* ] unit-test
[ { 3 4 } ] [ 2 4 1 10 <range> subseq ] unit-test
[ { 3 4 } ] [ 0 2 2 4 1 10 <range> <slice> subseq ] unit-test
[ "cba" ] [ 3 "abcdef" head-slice reverse ] unit-test

[ 1 2 3 ] [ 1 2 3 3vector 3unseq ] unit-test

[ 5040 ] [ [ 1 2 3 4 5 6 7 ] 1 [ * ] reduce ] unit-test

[ [ 1 1 2 6 24 120 720 ] ]
[ [ 1 2 3 4 5 6 7 ] 1 [ * ] accumilate ] unit-test
