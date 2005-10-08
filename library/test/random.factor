IN: temporary
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: random
USE: test
USE: errors

: check-random-int ( max -- )
    dup random-int 0 rot between?
    [ "Assertion failed" throw ] unless ;

[ ] [ 100 [ 674 check-random-int ] times ] unit-test
