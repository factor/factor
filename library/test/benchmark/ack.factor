USE: stack
USE: math
USE: kernel
USE: combinators
USE: compiler
USE: test

! http://inferno.bell-labs.com/cm/cs/who/bwk/interps/pap.html

: ack ( m n -- )
    over 0 = [
        nip succ
    ] [
        dup 0 = [
            drop pred 1 ack
        ] [
            dupd pred ack >r pred r> ack
        ] ifte
    ] ifte ; compiled

[ 4093 ] [ 3 9 ack ] unit-test
