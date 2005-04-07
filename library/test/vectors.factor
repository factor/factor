IN: temporary
USING: kernel kernel-internals math namespaces random sequences
strings test vectors ;

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

[ 5 list>vector ] unit-test-fails
[ { } ] [ [ ] list>vector ] unit-test
[ { 1 2 } ] [ [ 1 2 ] list>vector ] unit-test

[ t ] [
    100 empty-vector [ drop 0 100 random-int ] vector-map
    dup >list list>vector =
] unit-test

[ f ] [ { } { 1 2 3 } = ] unit-test
[ f ] [ { 1 2 } { 1 2 3 } = ] unit-test
[ f ] [ [ 1 2 ] { 1 2 3 } = ] unit-test
[ f ] [ { 1 2 } [ 1 2 3 ] = ] unit-test

[ [ 1 4 9 16 ] ]
[
    [ 1 2 3 4 ]
    list>vector [ dup * ] vector-map >list
] unit-test

[ t ] [ { } hashcode { } hashcode = ] unit-test
[ t ] [ { 1 2 3 } hashcode { 1 2 3 } hashcode = ] unit-test
[ t ] [ { 1 { 2 } 3 } hashcode { 1 { 2 } 3 } hashcode = ] unit-test
[ t ] [ { } hashcode { } hashcode = ] unit-test

[ { 1 2 3 4 5 6 } ]
[ { 1 2 3 } { 4 5 6 } vector-append ] unit-test

[ { "" "a" "aa" "aaa" } ]
[ 4 [ CHAR: a fill ] vector-project ]
unit-test

[ [ ] ] [ 0 { } vector-tail ] unit-test
[ [ ] ] [ 2 { 1 2 } vector-tail ] unit-test
[ [ 3 4 ] ] [ 2 { 1 2 3 4 } vector-tail ] unit-test
[ 2 [ ] vector-tail ] unit-test-fails

[ [ 3 ] ] [ 1 { 1 2 3 } vector-tail* ] unit-test

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
    { 1 2 3 4 } dup vector-array length
    >r clone vector-array length r>
    =
] unit-test

[ f ] [
    { 1 2 3 4 } dup clone
    swap vector-array swap vector-array eq?
] unit-test
