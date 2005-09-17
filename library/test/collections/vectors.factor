IN: temporary
USING: errors kernel kernel-internals lists math namespaces
random sequences sequences-internals strings test vectors ;

[ ] [ 10 [ [ -1000000 <vector> ] [ drop ] catch ] times ] unit-test

[ 3 ] [ [ t f t ] length ] unit-test
[ 3 ] [ { t f t } length ] unit-test

[ -3 { } nth ] unit-test-fails
[ 3 { } nth ] unit-test-fails
[ 3 #{ 1 2 }# nth ] unit-test-fails

[ "hey" [ 1 2 ] set-length ] unit-test-fails
[ "hey" { 1 2 } set-length ] unit-test-fails

[ 3 ] [ 3 0 <vector> [ set-length ] keep length ] unit-test
[ "yo" ] [
    "yo" 4 1 <vector> [ set-nth ] keep 4 swap nth
] unit-test

[ 1 { } nth ] unit-test-fails
[ -1 { } set-length ] unit-test-fails
[ { } ] [ [ ] >vector ] unit-test
[ { 1 2 } ] [ [ 1 2 ] >vector ] unit-test

[ t ] [
    100 [ drop 0 100 random-int ] map >vector
    dup >list >vector =
] unit-test

[ f ] [ { } { 1 2 3 } = ] unit-test
[ f ] [ { 1 2 } { 1 2 3 } = ] unit-test
[ f ] [ [ 1 2 ] { 1 2 3 } = ] unit-test
[ f ] [ { 1 2 } [ 1 2 3 ] = ] unit-test

[ [ 1 4 9 16 ] ]
[
    [ 1 2 3 4 ]
    >vector [ dup * ] map >list
] unit-test

[ t ] [ { } hashcode { } hashcode = ] unit-test
[ t ] [ { 1 2 3 } hashcode { 1 2 3 } hashcode = ] unit-test
[ t ] [ { 1 { 2 } 3 } hashcode { 1 { 2 } 3 } hashcode = ] unit-test
[ t ] [ { } hashcode { } hashcode = ] unit-test

[ { 1 2 3 } { 1 2 3 4 5 6 } ]
[ { 1 2 3 } dup { 4 5 6 } append ] unit-test

[ f ] [ f concat ] unit-test
[ { 1 2 3 4 } ] [ [ { 1 } [ 2 ] { 3 4 } ] concat ] unit-test

[ { } ] [ 0 { } tail ] unit-test
[ { } ] [ 2 { 1 2 } tail ] unit-test
[ { 3 4 } ] [ 2 { 1 2 3 4 } tail ] unit-test

[ { 3 } ] [ 1 { 1 2 3 } tail* ] unit-test

0 <vector> "funny-stack" set

[ ] [ { 1 5 } "funny-stack" get push ] unit-test
[ ] [ { 2 3 } "funny-stack" get push ] unit-test
[ { 2 3 } ] [ "funny-stack" get pop ] unit-test
[ { 1 5 } ] [ "funny-stack" get peek ] unit-test
[ { 1 5 } ] [ "funny-stack" get pop ] unit-test
[ "funny-stack" get pop ] unit-test-fails
[ "funny-stack" get pop ] unit-test-fails
[ ] [ "funky" "funny-stack" get push ] unit-test
[ "funky" ] [ "funny-stack" get pop ] unit-test

[ t ] [
    { 1 2 3 4 } dup underlying length
    >r clone underlying length r>
    =
] unit-test

[ f ] [
    { 1 2 3 4 } dup clone
    [ underlying ] 2apply eq?
] unit-test

[ 0 ] [
    [
        10 <vector> "x" set
        "x" get clone length
    ] with-scope
] unit-test

[ -1 ] [ 5 { } index ] unit-test
[ 4 ] [ 5 { 1 2 3 4 5 } index ] unit-test

[ t ] [
    100 >list dup >vector <reversed> >list >r reverse r> =
] unit-test
