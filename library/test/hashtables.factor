IN: scratchpad
USE: arithmetic
USE: combinators
USE: compiler
USE: hashtables
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: stack
USE: stdio
USE: strings
USE: test

"Checking hashtables" print

16 <hashtable> "testhash" set

: silly-key/value dup sq swap ;

1000 [ silly-key/value "testhash" get set-hash ] times*

[ f ]
[ 1000 count ]
[ [ silly-key/value "testhash" get hash = not ] subset ]
test-word

[ t ]
[ "testhash" get ]
[ hashtable? ]
test-word

[ f ]
[ [ 1 2 | 3 ] ]
[ hashtable? ]
test-word

[ f ]
[ namestack* ]
[ hashtable? ]
test-word
