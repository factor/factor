IN: temporary
USE: errors
USE: kernel
USE: math
USE: namespaces
USE: strings
USE: test

[ "Hello" ] [
    100 <sbuf> "buf" set
    "Hello" "buf" get sbuf-append
    "buf" get sbuf-clone "buf-clone" set
    "World" "buf-clone" get sbuf-append
    "buf" get sbuf>string
] unit-test

[ CHAR: h ] [ 0 s" hello world" sbuf-nth ] unit-test
