IN: scratchpad
USE: errors
USE: kernel
USE: namespaces
USE: stack
USE: test

[ f ] [ [ ] [ ] catch ] unit-test

[ 5 ] [ [ 5 throw ] [ ] catch ] unit-test

[ t ] [
    [ "Hello" throw ] [ drop ] catch
    global [ "error" get ] bind
    "Hello" =
] unit-test
