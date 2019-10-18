IN: scratchpad
USING: kernel kernel-internals math memory namespaces sequences
test errors ;

[ 0 ] [ f size ] unit-test
[ t ] [ [ \ = \ = ] all-equal? ] unit-test

! (clone) primitive was missing GC check
[ ] [ 1000000 [ drop H{ } clone >n n> drop ] each ] unit-test

[ t ] [ cell integer? ] unit-test
[ t ] [ bootstrap-cell integer? ] unit-test

[ [ 3 ] ] [ 3 f curry ] unit-test
[ [ \ + ] ] [ \ + f curry ] unit-test
[ [ \ + = ] ] [ \ + [ = ] curry ] unit-test

! Make sure we report the correct error on stack underflow
[ { kernel-error 11 f f } ]
[ [ clear drop ] catch ] unit-test
