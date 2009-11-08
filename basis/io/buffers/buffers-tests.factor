IN: io.buffers.tests
USING: alien alien.c-types alien.data io.buffers kernel
kernel.private libc sequences tools.test namespaces byte-arrays
strings accessors destructors ;

: buffer-set ( string buffer -- )
    over >byte-array over ptr>> byte-array>memory
    [ length ] dip buffer-reset ;

: string>buffer ( string -- buffer )
    dup length <buffer> [ buffer-set ] keep ;

: buffer-read-all ( buffer -- byte-array )
    [ [ pos>> ] [ ptr>> ] bi <displaced-alien> ]
    [ buffer-length ] bi
    memory>byte-array ;

[ B{ } 65536 ] [
    65536 <buffer>
    dup buffer-read-all
    over buffer-capacity
    rot dispose
] unit-test

[ "hello world" "" ] [
    "hello world" string>buffer
    dup buffer-read-all >string
    0 pick buffer-reset
    over buffer-read-all >string
    rot dispose
] unit-test

[ "hello" ] [
    "hello world" string>buffer
    5 over buffer-read >string swap dispose
] unit-test

[ 11 ] [
    "hello world" string>buffer
    [ buffer-length ] keep dispose
] unit-test

[ "hello world" ] [
    "hello" 1024 <buffer> [ buffer-set ] keep
    " world" >byte-array over >buffer
    dup buffer-read-all >string swap dispose
] unit-test

[ CHAR: e ] [
    "hello" string>buffer
    1 over buffer-consume [ buffer-pop ] keep dispose
] unit-test

"hello world" string>buffer "b" set
[ "hello world" ] [ 1000 "b" get buffer-read >string ] unit-test
"b" get dispose

100 <buffer> "b" set
[ 1000 "b" get n>buffer >string ] must-fail
"b" get dispose
