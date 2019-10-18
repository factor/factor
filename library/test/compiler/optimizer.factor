IN: scratchpad
USE: test
USE: compiler
USE: inference
USE: words
USE: math
USE: kernel
USE: lists

: foo 1 2 3 ;

[ [ ] ] [ \ foo word-parameter dataflow kill-set ] unit-test

[ [ [ + ] [ - ] ] ] [ [ 3 4 1 2 > [ + ] [ - ] ifte ] dataflow kill-set ] unit-test

[ [ [ 1 ] [ 2 ] ] ] [ [ [ 1 ] [ 2 ] ifte ] dataflow kill-set ] unit-test

[ [ [ 1 ] [ 2 ] ] ] [ [ t [ 1 ] [ 2 ] ifte ] dataflow kill-set ] unit-test

[ [ t t f ] ] [ [ 1 2 ] [ 1 2 3 ] [ f <literal> ] map kill-mask ] unit-test
