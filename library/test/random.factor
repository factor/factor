IN: scratchpad
USE: arithmetic
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: random
USE: stack
USE: test

[ t ]
[ [ 1 2 3 ] random-element number? ]
unit-test

[
    [ 10 | t ]
    [ 20 | f ]
    [ 30 | "monkey" ]
] "random-pairs" set

[ f ]
[
    "random-pairs" get
    random-element* [ t f "monkey" ] contains not
] unit-test

: check-random-int ( min max -- )
    2dup random-int -rot between? assert ;

[ ] [ 100 [ -12 674 check-random-int ] times ] unit-test
