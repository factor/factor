IN: scratchpad
USING: kernel kernel-internals math memory namespaces sequences
test ;

[ 0 ] [ f size ] unit-test
[ t ] [ [ \ = \ = ] all-equal? ] unit-test

! (clone) primitive was missing GC check
[ ] [ 1000000 [ drop H{ } clone >n n> drop ] each ] unit-test

[ t ] [ cell integer? ] unit-test
[ t ] [ bootstrap-cell integer? ] unit-test
