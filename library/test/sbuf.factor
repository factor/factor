IN: scratchpad
USE: combinators
USE: errors
USE: kernel
USE: logic
USE: math
USE: namespaces
USE: stack
USE: strings
USE: test

[ t ] [ "Foo" str>sbuf "Foo" str>sbuf = ] unit-test
[ f ] [ "Foo" str>sbuf "Foob" str>sbuf = ] unit-test
[ f ] [ 34 "Foo" str>sbuf = ] unit-test

[ "Hello" ] [
    100 <sbuf> "buf" set
    "Hello" "buf" get sbuf-append
    "buf" get sbuf-clone "buf-clone" set
    "World" "buf-clone" get sbuf-append
    "buf" get sbuf>str
] unit-test

[ t ] [
    "Hello world" str>sbuf hashcode
    "Hello world" hashcode =
] unit-test
