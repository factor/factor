IN: temporary
USE: test
USE: kernel
USE: compiler
USE: compiler-frontend
USE: inference
USE: words

: fie [ ] [ ] ifte ;

[ ] [ \ fie word-def dataflow linearize drop ] unit-test

: foo [ drop ] each-word ;

[ ] [ \ foo word-def dataflow linearize drop ] unit-test
