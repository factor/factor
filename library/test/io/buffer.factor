IN: temporary
USING: kernel io-internals test ;

[ "" 65536 ] [
    65536 <buffer>
    dup buffer-contents
    over buffer-capacity
    rot buffer-free
] unit-test

: buffer-set ( string buffer -- )
    2dup buffer-ptr string>memory
    >r string-length r> buffer-reset ;

[ "hello world" "" ] [
    "hello world" 65536 <buffer> [ buffer-set ] keep
    dup buffer-contents
    0 pick buffer-reset
    over buffer-contents
    rot buffer-free
] unit-test

[ "hello" ] [
    "hello world" 65536 <buffer> [ buffer-set ] keep
    5 over buffer-first-n swap buffer-free
] unit-test

[ 11 ] [
    "hello world" 65536 <buffer> [ buffer-set ] keep
    [ buffer-length ] keep buffer-free
] unit-test

[ "hello world" ] [
    "hello" 65536 <buffer> [ buffer-set ] keep
    " world" over buffer-append
    dup buffer-contents swap buffer-free
] unit-test
