USE: strings
USE: kernel
USE: math
USE: test
USE: lists
USE: namespaces
USE: compiler

! http://inferno.bell-labs.com/cm/cs/who/bwk/interps/pap.html

: string-step ( n str -- )
    2dup str-length > [
        dup [ "123" , , "456" , , "789" , ] make-string
        dup dup str-length 2 /i 0 swap rot substring
        swap dup str-length 2 /i 1 + 1 swap rot substring cat2
        string-step
    ] [
        2drop
    ] ifte ; compiled

: string-benchmark ( n -- )
    "abcdef" 10 [ 2dup string-step ] times 2drop ; compiled

[ ] [ 1000000 string-benchmark ] unit-test
