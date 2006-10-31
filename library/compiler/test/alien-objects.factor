IN: temporary
USING: alien arrays kernel kernel-internals namespaces test ;

[ t ] [ 0 <alien> 0 <alien> = ] unit-test
[ f ] [ 0 <alien> 1024 <alien> = ] unit-test
[ f ] [ "hello" 1024 <alien> = ] unit-test
[ f ] [ 0 <alien> ] unit-test
[ f ] [ 0 f <displaced-alien> ] unit-test

! Testing the various bignum accessor
10 <byte-array> "dump" set

[ "dump" get alien-address ] unit-test-fails

[ 123 ] [
    123 "dump" get 0 set-alien-signed-1
    "dump" get 0 alien-signed-1
] unit-test

[ 12345 ] [
    12345 "dump" get 0 set-alien-signed-2
    "dump" get 0 alien-signed-2
] unit-test

[ 12345678 ] [
    12345678 "dump" get 0 set-alien-signed-4
    "dump" get 0 alien-signed-4
] unit-test

[ 12345678901234567 ] [
    12345678901234567 "dump" get 0 set-alien-signed-8
    "dump" get 0 alien-signed-8
] unit-test

[ -1 ] [
    -1 "dump" get 0 set-alien-signed-8
    "dump" get 0 alien-signed-8
] unit-test

cell 8 = [
    [ HEX: 123412341234 ] [
      8 <byte-array>
      HEX: 123412341234 over 0 set-alien-signed-8
      0 alien-signed-8
    ] unit-test
    
    [ HEX: 123412341234 ] [
      8 <byte-array>
      HEX: 123412341234 over 0 set-alien-signed-cell
      0 alien-signed-cell
    ] unit-test
] when

[ "\u00ff" ]
[ "\u00ff" string>char-alien alien>char-string ]
unit-test

[ "hello world" ]
[ "hello world" string>char-alien alien>char-string ]
unit-test

[ "hello\uabcdworld" ]
[ "hello\uabcdworld" string>u16-alien alien>u16-string ]
unit-test

[ t ] [ f expired? ] unit-test
