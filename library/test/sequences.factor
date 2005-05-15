IN: temporary
USING: lists test sequences ;

[ [ 1 2 3 4 ] ] [ 1 4 <range> >list ] unit-test
[ 4 ] [ 1 4 <range> length ] unit-test
[ [ 4 3 2 1 ] ] [ 4 1 <range> >list ] unit-test
[ 2 ] [ 1 2 { 1 2 3 4 } <slice> length ] unit-test
[ [ 2 3 ] ] [ 1 2 { 1 2 3 4 } <slice> >list ] unit-test
