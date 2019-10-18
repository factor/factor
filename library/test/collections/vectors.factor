IN: temporary
USING: errors kernel kernel-internals lists math namespaces
sequences sequences-internals strings test vectors ;

[ ] [ 10 [ [ -1000000 <vector> ] catch drop ] times ] unit-test

[ 3 ] [ [ t f t ] length ] unit-test
[ 3 ] [ V{ t f t } length ] unit-test

[ -3 V{ } nth ] unit-test-fails
[ 3 V{ } nth ] unit-test-fails
[ 3 C{ 1 2 } nth ] unit-test-fails

[ "hey" [ 1 2 ] set-length ] unit-test-fails
[ "hey" V{ 1 2 } set-length ] unit-test-fails

[ 3 ] [ 3 0 <vector> [ set-length ] keep length ] unit-test
[ "yo" ] [
    "yo" 4 1 <vector> [ set-nth ] keep 4 swap nth
] unit-test

[ 1 V{ } nth ] unit-test-fails
[ -1 V{ } set-length ] unit-test-fails
[ V{ } ] [ [ ] >vector ] unit-test
[ V{ 1 2 } ] [ [ 1 2 ] >vector ] unit-test

[ t ] [
    100 [ drop 100 random-int ] map >vector
    dup >list >vector =
] unit-test

[ f ] [ V{ } V{ 1 2 3 } = ] unit-test
[ f ] [ V{ 1 2 } V{ 1 2 3 } = ] unit-test
[ f ] [ [ 1 2 ] V{ 1 2 3 } = ] unit-test
[ f ] [ V{ 1 2 } [ 1 2 3 ] = ] unit-test

[ [ 1 4 9 16 ] ]
[
    [ 1 2 3 4 ]
    >vector [ dup * ] map >list
] unit-test

[ t ] [ V{ } hashcode V{ } hashcode = ] unit-test
[ t ] [ V{ 1 2 3 } hashcode V{ 1 2 3 } hashcode = ] unit-test
[ t ] [ V{ 1 V{ 2 } 3 } hashcode V{ 1 V{ 2 } 3 } hashcode = ] unit-test
[ t ] [ V{ } hashcode V{ } hashcode = ] unit-test

[ V{ 1 2 3 } V{ 1 2 3 4 5 6 } ]
[ V{ 1 2 3 } dup V{ 4 5 6 } append ] unit-test

[ f ] [ f concat ] unit-test
[ V{ 1 2 3 4 } ] [ [ V{ 1 } [ 2 ] V{ 3 4 } ] concat ] unit-test

[ V{ } ] [ 0 V{ } tail ] unit-test
[ V{ } ] [ 2 V{ 1 2 } tail ] unit-test
[ V{ 3 4 } ] [ 2 V{ 1 2 3 4 } tail ] unit-test

[ V{ 3 } ] [ 1 V{ 1 2 3 } tail* ] unit-test

0 <vector> "funny-stack" set

[ ] [ V{ 1 5 } "funny-stack" get push ] unit-test
[ ] [ V{ 2 3 } "funny-stack" get push ] unit-test
[ V{ 2 3 } ] [ "funny-stack" get pop ] unit-test
[ V{ 1 5 } ] [ "funny-stack" get peek ] unit-test
[ V{ 1 5 } ] [ "funny-stack" get pop ] unit-test
[ "funny-stack" get pop ] unit-test-fails
[ "funny-stack" get pop ] unit-test-fails
[ ] [ "funky" "funny-stack" get push ] unit-test
[ "funky" ] [ "funny-stack" get pop ] unit-test

[ t ] [
    V{ 1 2 3 4 } dup underlying length
    >r clone underlying length r>
    =
] unit-test

[ f ] [
    V{ 1 2 3 4 } dup clone
    [ underlying ] 2apply eq?
] unit-test

[ 0 ] [
    [
        10 <vector> "x" set
        "x" get clone length
    ] with-scope
] unit-test

[ -1 ] [ 5 V{ } index ] unit-test
[ 4 ] [ 5 V{ 1 2 3 4 5 } index ] unit-test

[ t ] [
    100 >list dup >vector <reversed> >list >r reverse r> =
] unit-test
