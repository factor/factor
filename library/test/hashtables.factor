IN: scratchpad
USE: hashtables
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: test
USE: vectors

16 <hashtable> "testhash" set

: silly-key/value dup dup * swap ;

1000 [ silly-key/value "testhash" get set-hash ] times*

[ f ]
[ 1000 count [ silly-key/value "testhash" get hash = not ] subset ]
unit-test

[ t ]
[ "testhash" get hashtable? ]
unit-test

[ f ]
[ [[ 1 [[ 2 3 ]] ]] hashtable? ]
unit-test

! Test some hashcodes.

[ t ] [ [ 1 2 3 ] hashcode [ 1 2 3 ] hashcode = ] unit-test
[ t ] [ [[ f t ]] hashcode [[ f t ]] hashcode = ] unit-test
[ t ] [ [ 1 [ 2 3 ] 4 ] hashcode [ 1 [ 2 3 ] 4 ] hashcode = ] unit-test

[ t ] [ 12 hashcode 12 hashcode = ] unit-test
[ t ] [ 12 >bignum hashcode 12 hashcode = ] unit-test
[ t ] [ 12.0 hashcode 12 >bignum hashcode = ] unit-test

! Test various odd keys to see if they work.

16 <hashtable> "testhash" set

t #{ 2 3 }# "testhash" get set-hash
f 100 fac "testhash" get set-hash
{ } { [ { } ] } "testhash" get set-hash

[ t ] [ #{ 2 3 }# "testhash" get hash ] unit-test
[ f ] [ 100 fac "testhash" get hash* cdr ] unit-test
[ { } ] [ { [ { } ] } vector-clone "testhash" get hash* cdr ] unit-test

[
    [[ "salmon" "fish" ]]
    [[ "crocodile" "reptile" ]]
    [[ "cow" "mammal" ]]
    [[ "visual basic" "language" ]]
] alist>hash "testhash" set

[ f ] [
    "visual basic" "testhash" get remove-hash
    "visual basic" "testhash" get hash*
] unit-test
