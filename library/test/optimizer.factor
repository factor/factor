IN: scratchpad
USE: test
USE: compiler
USE: inference
USE: words
USE: math
USE: combinators

: foo 1 2 3 ;

[ [ ] ] [ \ foo word-parameter dataflow kill-set ] unit-test

[ [ [ + ] [ - ] ] ] [ [ 3 4 1 2 > [ + ] [ - ] ifte ] dataflow kill-set ] unit-test

[ [ [ 1 ] [ 2 ] ] ] [ [ [ 1 ] [ 2 ] ifte ] dataflow kill-set ] unit-test
