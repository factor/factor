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
[ [ 1 2 | 3 ] hashtable? ]
unit-test

! Test some hashcodes.

[ t ] [ [ 1 2 3 ] hashcode [ 1 2 3 ] hashcode = ] unit-test
[ t ] [ [ f | t ] hashcode [ f | t ] hashcode = ] unit-test
[ t ] [ [ 1 [ 2 3 ] 4 ] hashcode [ 1 [ 2 3 ] 4 ] hashcode = ] unit-test

[ t ] [ 12 hashcode 12 hashcode = ] unit-test
[ t ] [ 12 >bignum hashcode 12 hashcode = ] unit-test
[ t ] [ 12.0 hashcode 12 >bignum hashcode = ] unit-test
