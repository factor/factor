IN: scratchpad
USE: test
USE: kernel
USE: compiler
USE: inference
USE: words

: foo [ drop ] each-word ;

[ ] [ \ foo word-def dataflow linearize drop ] unit-test
