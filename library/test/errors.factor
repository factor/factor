IN: scratchpad
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

[ ] [ [ 6 [ 12 [ "2 car" ] ] ] default-error-handler ] unit-test

"!!! The following error is part of the test" print

[ [ "2 car" ] parse ] [ default-error-handler ] catch

[ [ "\"\" { } vector-nth" ] parse ] [ type-check-error ] catch

[ "cons" ] [ [ 1 2 ] type type-error-name ] unit-test
