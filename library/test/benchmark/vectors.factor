USE: vectors
USE: stack
USE: math
USE: compiler
USE: test

! http://inferno.bell-labs.com/cm/cs/who/bwk/interps/pap.html

: fill-vector ( n -- vector )
    dup <vector> swap [ dup pick set-vector-nth ] times* ;

: copy-elt ( vec-y vec-x n -- )
    #! Copy first nth element from vec-x to vec-y.
    tuck swap vector-nth transp set-vector-nth ;

: copy-vector ( vec-y vec-x n -- )
    #! Copy first n-1 elements from vec-x to vec-y.
    [ >r 2dup r> copy-elt ] times* 2drop ;

: vector-benchmark ( n -- )
    0 <vector> over fill-vector rot copy-vector ; ! compiled

[ ] [ 400000 vector-benchmark ] unit-test
