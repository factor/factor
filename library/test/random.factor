IN: scratchpad
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: random
USE: test

[ t ]
[ [ 1 2 3 ] random-element number? ]
unit-test

[
    [ 10 | t ]
    [ 20 | f ]
    [ 30 | "monkey" ]
    [ 24 | 1/2 ]
    [ 13 | { "Hello" "Banana" } ]
] "random-pairs" set

"random-pairs" get [ cdr ] map "random-values" set

[ f ]
[
    "random-pairs" get
    random-element* "random-values" get contains? not
] unit-test

: check-random-int ( min max -- )
    2dup random-int -rot between? assert ;

[ ] [ 100 [ -12 674 check-random-int ] times ] unit-test

: check-random-subset ( expected pairs -- )
    random-subset* [ over contains? ] all? nip ;

[ t ] [
    "random-values" get
    "random-pairs" get
    check-random-subset
] unit-test
