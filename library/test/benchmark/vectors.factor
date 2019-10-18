USING: compiler kernel math sequences test vectors ;

! http://inferno.bell-labs.com/cm/cs/who/bwk/interps/pap.html

: fill-vector ( n -- vector )
    dup <vector> swap [ dup pick set-nth ] each ; compiled

: copy-elt ( vec-y vec-x n -- )
    #! Copy nth element from vec-x to vec-y.
    rot >r tuck >r nth r> r> set-nth ; compiled

: copy-vector ( vec-y vec-x n -- )
    #! Copy first n-1 elements from vec-x to vec-y.
    [ [ >r 2dup r> copy-elt ] keep ] repeat 2drop ; compiled

: vector-benchmark ( n -- )
    0 <vector> over fill-vector rot copy-vector ; compiled

[ ] [ 400000 vector-benchmark ] unit-test
