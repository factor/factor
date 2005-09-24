USE: math
USE: kernel
USE: compiler
USE: test

! http://inferno.bell-labs.com/cm/cs/who/bwk/interps/pap.html

: ack ( m n -- x )
    over 0 = [
        nip 1+
    ] [
        dup 0 = [
            drop 1- 1 ack
        ] [
            dupd 1- ack >r 1- r> ack
        ] if
    ] if ; compiled

[ 4093 ] [ 3 9 ack ] unit-test
