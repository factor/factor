IN: scratchpad
USE: arithmetic
USE: hashtables
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: stack
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
