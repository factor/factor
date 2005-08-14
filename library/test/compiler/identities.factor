IN: temporary
USING: compiler kernel math test vectors ;

[ 5 ] [ 5 [ 0 + ] compile-1 ] unit-test
[ 5 ] [ 5 [ 0 swap + ] compile-1 ] unit-test

[ 5 ] [ 5 [ 0 - ] compile-1 ] unit-test
[ -5 ] [ 5 [ 0 swap - ] compile-1 ] unit-test
[ 0 ] [ 5 [ dup - ] compile-1 ] unit-test

[ 5 ] [ 5 [ 1 * ] compile-1 ] unit-test
[ 5 ] [ 5 [ 1 swap * ] compile-1 ] unit-test
[ 0 ] [ 5 [ 0 * ] compile-1 ] unit-test
[ 0 ] [ 5 [ 0 swap * ] compile-1 ] unit-test
[ -5 ] [ 5 [ -1 * ] compile-1 ] unit-test
[ -5 ] [ 5 [ -1 swap * ] compile-1 ] unit-test

[ 5 ] [ 5 [ 1 / ] compile-1 ] unit-test
[ 1/5 ] [ 5 [ 1 swap / ] compile-1 ] unit-test
[ -5 ] [ 5 [ -1 / ] compile-1 ] unit-test

[ 0 ] [ 5 [ 1 mod ] compile-1 ] unit-test
[ 0 ] [ 5 [ 1 rem ] compile-1 ] unit-test

[ 5 ] [ 5 [ 1 ^ ] compile-1 ] unit-test
[ 25 ] [ 5 [ 2 ^ ] compile-1 ] unit-test
[ 1/5 ] [ 5 [ -1 ^ ] compile-1 ] unit-test
[ 1/25 ] [ 5 [ -2 ^ ] compile-1 ] unit-test
[ 1 ] [ 5 [ 1 swap ^ ] compile-1 ] unit-test

[ 5 ] [ 5 [ -1 bitand ] compile-1 ] unit-test
[ 0 ] [ 5 [ 0 bitand ] compile-1 ] unit-test
[ 5 ] [ 5 [ -1 swap bitand ] compile-1 ] unit-test
[ 0 ] [ 5 [ 0 swap bitand ] compile-1 ] unit-test
[ 5 ] [ 5 [ dup bitand ] compile-1 ] unit-test

[ 5 ] [ 5 [ 0 bitor ] compile-1 ] unit-test
[ -1 ] [ 5 [ -1 bitor ] compile-1 ] unit-test
[ 5 ] [ 5 [ 0 swap bitor ] compile-1 ] unit-test
[ -1 ] [ 5 [ -1 swap bitor ] compile-1 ] unit-test
[ 5 ] [ 5 [ dup bitor ] compile-1 ] unit-test

[ 5 ] [ 5 [ 0 bitxor ] compile-1 ] unit-test
[ 5 ] [ 5 [ 0 swap bitxor ] compile-1 ] unit-test
[ -6 ] [ 5 [ -1 bitxor ] compile-1 ] unit-test
[ -6 ] [ 5 [ -1 swap bitxor ] compile-1 ] unit-test
[ 0 ] [ 5 [ dup bitxor ] compile-1 ] unit-test

[ 0 ] [ 5 [ 0 swap shift ] compile-1 ] unit-test
[ 5 ] [ 5 [ 0 shift ] compile-1 ] unit-test

[ f ] [ 5 [ dup < ] compile-1 ] unit-test
[ t ] [ 5 [ dup <= ] compile-1 ] unit-test
[ f ] [ 5 [ dup > ] compile-1 ] unit-test
[ t ] [ 5 [ dup >= ] compile-1 ] unit-test

[ t ] [ 5 [ dup eq? ] compile-1 ] unit-test
[ t ] [ 5 [ dup = ] compile-1 ] unit-test
[ t ] [ 5 [ dup number= ] compile-1 ] unit-test
[ t ] [ \ vector [ \ vector = ] compile-1 ] unit-test
