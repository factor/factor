IN: scratchpad
USING: kernel kernel-internals math memory namespaces sequences
test ;

[ 0 ] [ f size ] unit-test
[ t ] [ [ \ = \ = ] all-equal? ] unit-test

! (clone) primitive was missing GC check
[ ] [ 1000000 [ drop H{ } clone >n n> drop ] each ] unit-test

[ cell ] [ cell ] unit-test
[ t ] [ cell get integer? ] unit-test
