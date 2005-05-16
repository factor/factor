IN: temporary
USE: test
USE: assembler
USE: compiler
USE: compiler-frontend
USE: inference
USE: words
USE: math
USE: kernel
USE: lists
USE: sequences

: foo 1 2 3 ;

[ [ ] ] [ \ foo word-def dataflow kill-set ] unit-test

[ [ [ 1 ] [ 2 ] ] ] [ [ [ 1 ] [ 2 ] ifte ] dataflow kill-set ] unit-test

[ [ [ 1 ] [ 2 ] ] ] [ [ [ 1 ] [ 2 ] ifte ] dataflow kill-set ] unit-test

[ [ t t f ] ] [ [ 1 2 ] [ 1 2 3 ] [ f <literal> ] map kill-mask ] unit-test

[ t ] [ 3 [ 3 over [ ] [ ] ifte drop ] dataflow kill-set contains? ] unit-test

: literal-kill-test-1 4 compiled-offset cell 2 * - ; compiled

[ 4 ] [ literal-kill-test-1 drop ] unit-test

: literal-kill-test-2 3 compiled-offset cell 2 * - ; compiled

[ 3 ] [ literal-kill-test-2 drop ] unit-test

: literal-kill-test-3 10 3 /mod drop ; compiled

[ 3 ] [ literal-kill-test-3 ] unit-test
