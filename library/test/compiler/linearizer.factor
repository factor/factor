IN: scratchpad
USE: test
USE: kernel
USE: compiler
USE: inference
USE: words

: foo [ drop ] each-word ;

[ ] [ \ foo word-parameter dataflow linearize drop ] unit-test
