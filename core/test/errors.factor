IN: temporary
USE: sequences
USE: errors
USE: kernel
USE: namespaces
USE: test
USE: parser
USE: io
USE: memory

[ clear drop ] unit-test-fails

[ f ] [ [ ] catch ] unit-test

[ 5 ] [ [ 5 throw ] catch ] unit-test

[ t ] [
    [ "Hello" throw ] catch drop
    global [ error get ] bind
    "Hello" =
] unit-test

"!!! The following error is part of the test" print

[ ] [ [ 6 [ 12 [ "2 car" ] ] ] print-error ] unit-test

"!!! The following error is part of the test" print

[ [ "2 car" ] parse ] catch print-error

[ f throw ] unit-test-fails

! See how well callstack overflow is handled
: callstack-overflow callstack-overflow f ;
[ callstack-overflow ] unit-test-fails

! Weird PowerPC bug.
[ ] [
    [ "4" throw ] catch drop
    full-gc
    full-gc
] unit-test

[ f ] [ { "A" "B" } kernel-error? ] unit-test
