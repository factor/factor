USING: accessors alien alien.accessors alien.syntax byte-arrays arrays
kernel kernel.private namespaces tools.test sequences libc math
system prettyprint layouts alien.libraries ;
IN: alien.tests

[ t ] [ -1 <alien> alien-address 0 > ] unit-test

[ t ] [ 0 <alien> 0 <alien> = ] unit-test
[ f ] [ 0 <alien> 1024 <alien> = ] unit-test
[ f ] [ "hello" 1024 <alien> = ] unit-test
[ f ] [ 0 <alien> ] unit-test
[ f ] [ 0 f <displaced-alien> ] unit-test

! Testing the various bignum accessor
10 <byte-array> "dump" set

[ "dump" get alien-address ] must-fail

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

[ "ALIEN: 1234" ] [ 1234 <alien> unparse ] unit-test

[ ] [ 0 B{ 1 2 3 } <displaced-alien> drop ] unit-test

[ 0 B{ 1 2 3 } <displaced-alien> alien-address ] must-fail

[ 1 1 <displaced-alien> ] must-fail

[ f ] [ 0 B{ 1 2 3 } <displaced-alien> pinned-c-ptr? ] unit-test

[ f ] [ 0 B{ 1 2 3 } <displaced-alien> 1 swap <displaced-alien> pinned-c-ptr? ] unit-test

[ t ] [ 0 B{ 1 2 3 } <displaced-alien> 1 swap <displaced-alien> underlying>> byte-array? ] unit-test

[ "( displaced alien )" ] [ 0 B{ 1 2 3 } <displaced-alien> unparse ] unit-test

[ f ] [ DLL" fadfasdfsada" dll-valid? ] unit-test

[ f ] [ "does not exist" DLL" fadsfasfdsaf" dlsym ] unit-test

SYMBOL: initialize-test

f initialize-test set-global

[ 31337 ] [ initialize-test [ 31337 ] initialize-alien ] unit-test

[ 31337 ] [ initialize-test [ 69 ] initialize-alien ] unit-test

[ ] [ initialize-test get BAD-ALIEN >>alien drop ] unit-test

[ 7575 ] [ initialize-test [ 7575 ] initialize-alien ] unit-test
