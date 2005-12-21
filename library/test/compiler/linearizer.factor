IN: temporary
USE: test
USE: kernel
USE: compiler
USE: compiler-frontend
USE: inference
USE: words

: fie [ ] [ ] if ;

[ ] [ \ fie dup word-def dataflow linearize drop ] unit-test

: foo [ drop ] each-word ;

[ ] [ \ foo dup word-def dataflow linearize drop ] unit-test
