IN: scratchpad
USE: compiler
USE: test
USE: inference
USE: lists

[ [ ] ] [ [ ] simplify ] unit-test
[ [ [ #return ] ] ] [ [ [ #return ] ] simplify ] unit-test
[ [ [ #jump | car ] ] ] [ [ [ #call | car ] [ #return ] ] simplify ] unit-test

[ [ [ #return ] ] ]
[ 123 [ [ #call | car ] [ #label | 123 ] [ #return ] ] find-label ]
unit-test
