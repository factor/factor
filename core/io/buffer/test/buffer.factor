IN: temporary
USING: alien io-internals kernel kernel-internals libc
sequences test ;

: buffer-set ( string buffer -- )
    2dup buffer-ptr string>memory
    >r length r> buffer-reset ;

: string>buffer ( string -- buffer )
    dup length <buffer> tuck buffer-set ;

[ "" 65536 ] [
    65536 <buffer>
    dup buffer-contents
    over buffer-capacity
    rot buffer-free
] unit-test

[ "hello world" "" ] [
    "hello world" string>buffer
    dup buffer-contents
    0 pick buffer-reset
    over buffer-contents
    rot buffer-free
] unit-test

[ "hello" ] [
    "hello world" string>buffer
    5 over buffer-first-n swap buffer-free
] unit-test

[ 11 ] [
    "hello world" string>buffer
    [ buffer-length ] keep buffer-free
] unit-test

[ "hello world" ] [
    "hello" 1024 <buffer> [ buffer-set ] keep
    " world" over >buffer
    dup buffer-contents swap buffer-free
] unit-test

[ CHAR: e ] [
    "hello" string>buffer
    1 over buffer-consume [ buffer-pop ] keep buffer-free
] unit-test
