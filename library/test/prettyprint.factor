IN: scratchpad
USE: lists
USE: prettyprint
USE: stdio
USE: test
USE: vocabularies

"Checking prettyprinter." print

! This was broken due to uninterned words having a null vocabulary.
[ #:uninterned ] prettyprint

! Now do a little benchmark
[ vocabs [ words [ see ] each ] each ] time
