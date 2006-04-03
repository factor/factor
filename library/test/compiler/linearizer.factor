IN: temporary
USE: test
USE: kernel
USE: compiler
USE: inference
USE: words
USE: sequences

: fie [ ] [ ] if ;

[ ] [ \ fie dup word-def dataflow linearize drop ] unit-test

: foo all-words [ drop ] each ;

[ ] [ \ foo dup word-def dataflow linearize drop ] unit-test
