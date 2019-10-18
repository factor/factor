USING: compiler kernel math namespaces sequences strings test ;

! http://inferno.bell-labs.com/cm/cs/who/bwk/interps/pap.html

: string-step ( n str -- )
    2dup length > [
        dup [ "123" % % "456" % % "789" % ] make-string
        dup dup length 2 /i 0 swap rot subseq
        swap dup length 2 /i 1 + 1 swap rot subseq append
        string-step
    ] [
        2drop
    ] ifte ; compiled

: string-benchmark ( n -- )
    "abcdef" 10 [ 2dup string-step ] times 2drop ; compiled

[ ] [ 400000 string-benchmark ] unit-test
