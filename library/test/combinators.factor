IN: scratchpad
USE: arithmetic
USE: combinators
USE: kernel
USE: lists
USE: stack
USE: stdio
USE: test
USE: words

! Tests the combinators.

"Checking combinators." print

[   ] [ 3 ] [ [ ] cond ] test-word
[ t ] [ 4 ] [ [ [ 1 = ] [ ] [ 4 = ] [ drop t ] [ 2 = ] [ ] ] cond ] test-word

[ [ 1 2 3 ] ] [ [ 1 4 2 5 3 6 ] [ 4 < ] ] [ subset ] test-word
