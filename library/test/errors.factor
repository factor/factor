IN: temporary
USING: memory ;
USE: errors
USE: kernel
USE: namespaces
USE: test
USE: lists
USE: parser
USE: io

[ f ] [ [ ] [ ] catch ] unit-test

[ 5 ] [ [ 5 throw ] [ ] catch ] unit-test

[ t ] [
    [ "Hello" throw ] [ drop ] catch
    global [ "error" get ] bind
    "Hello" =
] unit-test

"!!! The following error is part of the test" print

[ ] [ [ 6 [ 12 [ "2 car" ] ] ] print-error ] unit-test

"!!! The following error is part of the test" print

[ [ "2 car" ] parse ] [ print-error ] catch

! This should not raise an error
[ 1 2 3 ] [ 1 2 3 f throw ] unit-test

! See how well callstack overflow is handled
: callstack-overflow callstack-overflow f ;
[ callstack-overflow ] unit-test-fails

! Weird PowerPC bug.
[ ] [
    [ "4" throw ] [ drop ] catch
    full-gc
    full-gc
] unit-test
