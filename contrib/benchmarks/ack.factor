USE: math
USE: kernel
USE: compiler
USE: test

! http://inferno.bell-labs.com/cm/cs/who/bwk/interps/pap.html

: ack ( m n -- x )
    over zero? [
        nip 1+
    ] [
        dup zero? [
            drop 1- 1 ack
        ] [
            dupd 1- ack >r 1- r> ack
        ] if
    ] if ;

[ 4093 ] [ 3 9 ack ] unit-test
