IN: temporary
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: random
USE: test

: check-random-int ( min max -- )
    2dup random-int -rot between? assert ;

[ ] [ 100 [ -12 674 check-random-int ] times ] unit-test
