IN: scratchpad
USE: errors
USE: kernel
USE: math
USE: namespaces
USE: parser
USE: stack
USE: strings
USE: test
USE: vectors

! Various things that broke CFactor at various times.
! This should run without issue (and tests nothing useful)
! in Java Factor

"20 <sbuf> \"foo\" set" eval
"garbage-collection" eval

[
    [ drop ] [ drop ] catch
    [ drop ] [ drop ] catch
] keep-datastack

"hello" str>sbuf "x" set
[ -5 "x" get set-sbuf-length ] [ drop ] catch
[ "x" get sbuf>str drop ] [ drop ] catch

10 <vector> "x" set
[ -2 "x" get set-vector-length ] [ drop ] catch
[ "x" get clone drop ] [ drop ] catch

10 [ [ -1000000 <vector> ] [ drop ] catch ] times

10 [ [ -1000000 <sbuf> ] [ drop ] catch ] times
