IN: scratchpad
USE: kernel
USE: namespaces
USE: parser
USE: strings
USE: test

! Various things that broke the CFactor GC at various times.
! This should run without issue (and tests nothing useful)
! in Java Factor

! This was bloody stupid of me
"20 <sbuf> \"foo\" set" eval
"garbage-collection" eval

