USE: strings
USE: kernel
USE: math
USE: test
USE: unparser
USE: hashtables

! http://inferno.bell-labs.com/cm/cs/who/bwk/interps/pap.html

: store-hash ( hashtable n -- )
    [ dup >hex swap pick set-hash ] times* drop ;

: lookup-hash ( hashtable n -- )
    [ unparse over hash drop ] times* drop ;

: hashtable-benchmark ( n -- )
    60000 <hashtable> swap 2dup store-hash lookup-hash ;

[ ] [ 80000 hashtable-benchmark ] unit-test
