USING: kernel sets tools.test ;
IN: sets.tests

[ f ] [ { 0 1 1 2 3 5 } all-unique? ] unit-test
[ t ] [ { 0 1 2 3 4 5 } all-unique? ] unit-test

[ V{ 1 2 3 } ] [ { 1 2 2 3 3 } prune ] unit-test
[ V{ 3 2 1 } ] [ { 3 3 2 2 1 } prune ] unit-test

[ { } ] [ { } { } intersect  ] unit-test
[ { 2 3 } ] [ { 1 2 3 } { 2 3 4 } intersect ] unit-test

[ { } ] [ { } { } diff ] unit-test
[ { 4 } ] [ { 1 2 3 } { 2 3 4 } diff ] unit-test

[ V{ } ] [ { } { } union ] unit-test
[ V{ 1 2 3 4 } ] [ { 1 2 3 } { 2 3 4 } union ] unit-test
