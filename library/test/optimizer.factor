IN: scratchpad
USE: test
USE: compiler
USE: inference
USE: words

: foo 1 2 3 ;

[ [ ] ] [ \ foo word-parameter dataflow kill-set ] unit-test
