USING: sequences.next tools.test arrays kernel math sequences ;

[ { { 1 0 } { 2 1 } { f 2 } } ] [ 3 [ 2array ] map-next ] unit-test

[ 8 ] [ 3 [ 1+ ] map 0 swap [ swap [ + + ] [ drop ] if* ] each-next ] unit-test
