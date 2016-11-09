IN: io.buffers.tests
USING: accessors alien alien.data arrays byte-arrays destructors
io.buffers kernel libc namespaces sequences strings tools.test ;

: buffer-set ( string buffer -- )
    [ ptr>> swap >byte-array binary-object memcpy ]
    [ [ length ] dip buffer-reset ]
    2bi ;

: string>buffer ( string -- buffer )
    dup length <buffer> [ buffer-set ] keep ;

: buffer-read-all ( buffer -- byte-array )
    [ buffer@ ] [ buffer-length ] bi memory>byte-array ;

{ B{ } 65536 } [
    65536 <buffer>
    dup buffer-read-all
    over buffer-capacity
    rot dispose
] unit-test

{ "hello world" "" } [
    "hello world" string>buffer
    dup buffer-read-all >string
    0 pick buffer-reset
    over buffer-read-all >string
    rot dispose
] unit-test

{ "hello" } [
    "hello world" string>buffer
    5 over buffer-read >string swap dispose
] unit-test

{ 11 } [
    "hello world" string>buffer
    [ buffer-length ] keep dispose
] unit-test

{ "hello world" } [
    "hello" 1024 <buffer> [ buffer-set ] keep
    " world" >byte-array binary-object pick buffer-write
    dup buffer-read-all >string swap dispose
] unit-test

{ CHAR: e } [
    "hello" string>buffer
    1 over buffer-consume [ buffer-pop ] keep dispose
] unit-test

"hello world" string>buffer "b" set
{ "hello world" } [ 1000 "b" get buffer-read >string ] unit-test
"b" get dispose

100 <buffer> "b" set
[ 1000 "b" get buffer+ >string ] must-fail
"b" get dispose

"hello world" string>buffer "b" set
{ "hello" CHAR: \s } [ " " "b" get buffer-read-until [ >string ] dip ] unit-test
"b" get dispose

"hello world" string>buffer "b" set
{ "hello worl" CHAR: d } [ "d" "b" get buffer-read-until [ >string ] dip ] unit-test
"b" get dispose

"hello world" string>buffer "b" set
{ "hello world" f } [ "\n" "b" get buffer-read-until [ >string ] dip ] unit-test
"b" get dispose

{ 4 B{ 1 2 3 4 0 0 0 0 0 0 } } [
    10 <buffer>
    [ B{ 1 2 3 4 } binary-object rot buffer-write ]
    [ 10 <byte-array> [ 10 rot buffer-read-into ] keep ] bi
] unit-test

{ 4 { 1 2 3 4 f f f f f f } } [
    10 <buffer>
    [ B{ 1 2 3 4 } binary-object rot buffer-write ]
    [ 10 f <array> [ 10 rot buffer-read-into ] keep ] bi
] unit-test
