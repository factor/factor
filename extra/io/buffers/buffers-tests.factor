IN: io.buffers.tests
USING: alien alien.c-types io.buffers kernel kernel.private libc
sequences tools.test namespaces byte-arrays strings ;

: buffer-set ( string buffer -- )
    over >byte-array over buffer-ptr byte-array>memory
    >r length r> buffer-reset ;

: string>buffer ( string -- buffer )
    dup length <buffer> tuck buffer-set ;

[ B{ } 65536 ] [
    65536 <buffer>
    dup (buffer>>)
    over buffer-capacity
    rot buffer-free
] unit-test

[ "hello world" "" ] [
    "hello world" string>buffer
    dup (buffer>>) >string
    0 pick buffer-reset
    over (buffer>>) >string
    rot buffer-free
] unit-test

[ "hello" ] [
    "hello world" string>buffer
    5 over buffer> >string swap buffer-free
] unit-test

[ 11 ] [
    "hello world" string>buffer
    [ buffer-length ] keep buffer-free
] unit-test

[ "hello world" ] [
    "hello" 1024 <buffer> [ buffer-set ] keep
    " world" >byte-array over >buffer
    dup (buffer>>) >string swap buffer-free
] unit-test

[ CHAR: e ] [
    "hello" string>buffer
    1 over buffer-consume [ buffer-pop ] keep buffer-free
] unit-test

[ "hello" CHAR: \r ] [
    "hello\rworld" string>buffer
    "\r" over buffer-until >r >string r>
    rot buffer-free
] unit-test

[ "hello" CHAR: \r ] [
    "hello\rworld" string>buffer
    "\n\r" over buffer-until >r >string r>
    rot buffer-free
] unit-test

[ "hello\rworld" f ] [
    "hello\rworld" string>buffer
    "X" over buffer-until >r >string r>
    rot buffer-free
] unit-test

[ "hello" CHAR: \r "world" CHAR: \n ] [
    "hello\rworld\n" string>buffer
    [ "\r\n" swap buffer-until >r >string r> ] keep
    [ "\r\n" swap buffer-until >r >string r> ] keep
    buffer-free
] unit-test

"hello world" string>buffer "b" set
[ "hello world" ] [ 1000 "b" get buffer> >string ] unit-test
"b" get buffer-free

100 <buffer> "b" set
[ 1000 "b" get n>buffer >string ] must-fail
"b" get buffer-free
