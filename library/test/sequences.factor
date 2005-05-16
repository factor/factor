IN: temporary
USING: lists sequences test vectors ;

[ [ 1 2 3 4 ] ] [ 1 5 <range> >list ] unit-test
[ 3 ] [ 1 4 <range> length ] unit-test
[ [ 4 3 2 1 ] ] [ 4 0 <range> >list ] unit-test
[ 2 ] [ 1 3 { 1 2 3 4 } <slice> length ] unit-test
[ [ 2 3 ] ] [ 1 3 { 1 2 3 4 } <slice> >list ] unit-test
[ { 4 5 } ] [ 2 { 1 2 3 4 5 } tail-slice >vector ] unit-test
