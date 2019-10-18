IN: scratchpad
USE: arithmetic
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: random
USE: stdio
USE: test

"Checking random number generation." print

[ t ]
[ [ 1 2 3 ] ]
[ random-element number? ]
test-word

[
    [ 10 | t ]
    [ 20 | f ]
    [ 30 | "monkey" ]
] "random-pairs" set

[ f ]
[ "random-pairs" get ]
[ random-element* [ t f "monkey" ] contains not ] test-word

"Random number checks complete." print
