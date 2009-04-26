IN: binary-search.tests
USING: binary-search math.order vectors kernel tools.test ;

[ f ] [ 3 { } [ <=> ] with search drop ] unit-test
[ 0 ] [ 3 { 3 } [ <=> ] with search drop ] unit-test
[ 1 ] [ 2 { 1 2 3 } [ <=> ] with search drop ] unit-test
[ 3 ] [ 4 { 1 2 3 4 5 6 } [ <=> ] with search drop ] unit-test
[ 2 ] [ 3.5 { 1 2 3 4 5 6 7 8 } [ <=> ] with search drop ] unit-test
[ 4 ] [ 5.5 { 1 2 3 4 5 6 7 8 } [ <=> ] with search drop ] unit-test
[ 10 ] [ 10 20 >vector [ <=> ] with search drop ] unit-test

[ t ] [ "hello" { "alligrator" "cat" "fish" "hello" "ikarus" "java" } sorted-member? ] unit-test
[ 3 ] [ "hey" { "alligrator" "cat" "fish" "hello" "ikarus" "java" } sorted-index ] unit-test
[ f ] [ "hello" { "alligrator" "cat" "fish" "ikarus" "java" } sorted-member? ] unit-test
[ f ] [ "zebra" { "alligrator" "cat" "fish" "ikarus" "java" } sorted-member? ] unit-test
