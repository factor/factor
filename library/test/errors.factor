IN: temporary
USE: errors
USE: kernel
USE: namespaces
USE: test
USE: lists
USE: parser
USE: stdio

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

! [ [ "\"\" { } vector-nth" ] parse ] [ type-check-error ] catch

! This should not raise an error
[ ] [ f throw ] unit-test
