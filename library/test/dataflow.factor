IN: scratchpad
USE: inference
USE: lists
USE: math
USE: test
USE: logic
USE: combinators

[ t ] [ \ + [ 2 2 + ] dataflow tree-contains? >boolean ] unit-test
[ t ] [ 3 [ [ sq ] [ 3 + ] ifte ] dataflow tree-contains? >boolean ] unit-test

: inline-test
    car car ; inline

[ t ] [ \ car [ inline-test ] dataflow tree-contains? >boolean ] unit-test
