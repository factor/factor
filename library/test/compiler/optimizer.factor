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

: kill-set*
    dataflow kill-set [ literal-value ] map ;

: foo 1 2 3 ;

[ [ ] ] [ \ foo word-def dataflow kill-set ] unit-test

[ [ [ 1 ] [ 2 ] ] ] [ [ [ 1 ] [ 2 ] ifte ] kill-set* ] unit-test

[ [ [ 1 ] [ 2 ] ] ] [ [ [ 1 ] [ 2 ] ifte ] kill-set* ] unit-test

[ [ t t f ] ] [
    [ 1 2 3 ] [ f <literal> ] map
    [ [ literal-value 2 <= ] subset ] keep in-d-node <#drop> kill-mask
] unit-test

[ t ] [
    3 [ 3 over [ ] [ ] ifte drop ] dataflow
    kill-set [ value= ] contains-with?
] unit-test

: literal-kill-test-1 4 compiled-offset cell 2 * - ; compiled

[ 4 ] [ literal-kill-test-1 drop ] unit-test

: literal-kill-test-2 3 compiled-offset cell 2 * - ; compiled

[ 3 ] [ literal-kill-test-2 drop ] unit-test

: literal-kill-test-3 10 3 /mod drop ; compiled

[ 3 ] [ literal-kill-test-3 ] unit-test

[ [ [ 3 ] [ dup ] ] ] [ [ [ 3 ] [ dup ] ifte drop ] kill-set* ] unit-test

: literal-kill-test-4
    5 swap [ 3 ] [ dup ] ifte 2drop ; compiled

[ ] [ t literal-kill-test-4 ] unit-test
[ ] [ f literal-kill-test-4 ] unit-test

[ [ [ 3 ] [ dup ] ] ] [ \ literal-kill-test-4 word-def kill-set* ] unit-test

: literal-kill-test-5
    5 swap [ 5 ] [ dup ] ifte 2drop ; compiled

[ ] [ t literal-kill-test-5 ] unit-test
[ ] [ f literal-kill-test-5 ] unit-test

[ [ [ 5 ] [ dup ] ] ] [ \ literal-kill-test-5 word-def kill-set* ] unit-test

: literal-kill-test-6
    5 swap [ dup ] [ dup ] ifte 2drop ; compiled

[ ] [ t literal-kill-test-6 ] unit-test
[ ] [ f literal-kill-test-6 ] unit-test

[ [ 5 [ dup ] [ dup ] ] ] [ \ literal-kill-test-6 word-def kill-set* ] unit-test

: literal-kill-test-7
    [ 1 2 3 ] >r + r> drop ; compiled

[ 4 ] [ 2 2 literal-kill-test-7 ] unit-test
