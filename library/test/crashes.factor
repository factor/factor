IN: scratchpad
USE: errors
USE: kernel
USE: namespaces
USE: parser
USE: stack
USE: strings
USE: test

! Various things that broke CFactor at various times.
! This should run without issue (and tests nothing useful)
! in Java Factor

"20 <sbuf> \"foo\" set" eval
"garbage-collection" eval

[
    [ drop ] [ drop ] catch
    [ drop ] [ drop ] catch
] keep-datastack
