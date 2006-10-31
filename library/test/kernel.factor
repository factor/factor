IN: scratchpad
USING: kernel kernel-internals math memory namespaces sequences
test errors math-internals ;

[ 0 ] [ f size ] unit-test
[ t ] [ [ \ = \ = ] all-equal? ] unit-test

! some primitives are missing GC checks
[ ] [ 1000000 [ drop H{ } clone >n n> drop ] each ] unit-test
[ ] [ 1.0 10000000 [ drop 1.0 * ] each ] unit-test
[ ] [ 268435455 >fixnum 10000000 [ drop dup dup + drop ] each ] unit-test
[ ] [ 268435455 >fixnum 10000000 [ drop dup dup fixnum+ drop ] each ] unit-test
[ ] [ 10000000 [ drop 1/3 >fixnum drop ] each ] unit-test
[ ] [ 10000000 [ drop 1/3 >bignum drop ] each ] unit-test
[ ] [ 10000000 [ drop 1/3 >float drop ] each ] unit-test

! Don't leak extra roots if error is thrown
[ ] [ 10000 [ [ -1 f <array> ] catch drop ] times ] unit-test

[ t ] [ cell integer? ] unit-test
[ t ] [ bootstrap-cell integer? ] unit-test

[ [ 3 ] ] [ 3 f curry ] unit-test
[ [ \ + ] ] [ \ + f curry ] unit-test
[ [ \ + = ] ] [ \ + [ = ] curry ] unit-test

! Make sure we report the correct error on stack underflow
[ { kernel-error 11 f f } ]
[ [ clear drop ] catch ] unit-test
