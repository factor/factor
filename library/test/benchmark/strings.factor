USE: stack
USE: strings
USE: math
USE: combinators
USE: test

! http://inferno.bell-labs.com/cm/cs/who/bwk/interps/pap.html

: string-step ( n str -- )
    2dup str-length > [
        dup <% "123" % % "456" % % "789" % %>
        dup dup str-length 2 /i 0 transp substring
        swap dup str-length 2 /i succ 1 transp substring cat2
        string-step
    ] [
        2drop
    ] ifte ;

: string-benchmark ( n -- )
    "abcdef" 10 [ 2dup string-step ] times 2drop ;

[ ] [ 1000000 string-benchmark ] unit-test
