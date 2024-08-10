USING: accessors alien alien.accessors alien.c-types
alien.syntax byte-arrays continuations kernel layouts math
namespaces prettyprint sequences tools.memory tools.test ;
QUALIFIED: sets
IN: alien.tests

{ t } [ -1 <alien> alien-address 0 > ] unit-test

{ t } [ 0 <alien> 0 <alien> = ] unit-test
{ f } [ 0 <alien> 1024 <alien> = ] unit-test
{ f } [ "hello" 1024 <alien> = ] unit-test
{ f } [ 0 <alien> ] unit-test
{ f } [ 0 f <displaced-alien> ] unit-test

! Testing the various bignum accessor
10 <byte-array> "dump" set

[ "dump" get alien-address ] must-fail

{ 123 } [
    123 "dump" get 0 set-alien-signed-1
    "dump" get 0 alien-signed-1
] unit-test

{ 12345 } [
    12345 "dump" get 0 set-alien-signed-2
    "dump" get 0 alien-signed-2
] unit-test

{ 12345678 } [
    12345678 "dump" get 0 set-alien-signed-4
    "dump" get 0 alien-signed-4
] unit-test

{ 12345678901234567 } [
    12345678901234567 "dump" get 0 set-alien-signed-8
    "dump" get 0 alien-signed-8
] unit-test

{ -1 } [
    -1 "dump" get 0 set-alien-signed-8
    "dump" get 0 alien-signed-8
] unit-test

[ 0x123412341234 ] [
    0x123412341234 "dump" get 0 set-alien-signed-8
    "dump" get 0 alien-signed-8
] unit-test

{ "ALIEN: 1234" } [ 0x1234 <alien> unparse ] unit-test

[ 0 B{ 1 2 3 } <displaced-alien> ] must-not-fail

[ 0 B{ 1 2 3 } <displaced-alien> alien-address ] must-fail

[ 1 1 <displaced-alien> ] must-fail

{ f } [ 1 B{ 1 2 3 } <displaced-alien> pinned-c-ptr? ] unit-test

{ f } [ 2 B{ 1 2 3 } <displaced-alien> 1 swap <displaced-alien> pinned-c-ptr? ] unit-test

{ t } [ 0 B{ 1 2 3 } <displaced-alien> 1 swap <displaced-alien> underlying>> byte-array? ] unit-test

{ "( displaced alien )" } [ 1 B{ 1 2 3 } <displaced-alien> unparse ] unit-test

SYMBOL: initialize-test

f initialize-test set-global

{ 31337 } [ initialize-test [ 31337 ] initialize-alien ] unit-test

{ 31337 } [ initialize-test [ 69 ] initialize-alien ] unit-test

[ initialize-test get BAD-ALIEN >>alien ] must-not-fail

{ 7575 } [ initialize-test [ 7575 ] initialize-alien ] unit-test

{ { BAD-ALIEN } } [ { BAD-ALIEN BAD-ALIEN BAD-ALIEN } sets:members ] unit-test

! Generate callbacks until the whole callback-heap is full, then free
! them. Do it ten times in a row for good measure.
: produce-until-error ( quot -- error seq )
    '[ [ @ t ] [ f ] recover ] [ ] produce ; inline

SYMBOL: foo

: fill-and-free-callback-heap ( -- )
    [ \ foo 33 <callback> ] produce-until-error nip [ free-callback ] each ;

{ } [
    10 [ fill-and-free-callback-heap ] times
] unit-test

: <cb-creator> ( -- alien )
    \ int { pointer: void pointer: void } \ cdecl
    [ 2drop 37 ] alien-callback ;

: call-cb ( -- ret )
    f f <cb-creator> [
        \ int { pointer: void pointer: void } \ cdecl
        alien-indirect
    ] with-callback ;

! This function shouldn't leak
{ t } [
    callback-room occupied>>
    call-cb drop
    callback-room occupied>> =
] unit-test

! Will fail if the callbacks cache gets out of sync
{ 37 37 } [
    call-cb
    fill-and-free-callback-heap
    call-cb
] unit-test

[ void { } cdecl [ ] alien-assembly ] [ callsite-not-compiled? ] must-fail-with
[ void f "flor" { } f alien-invoke ] [ callsite-not-compiled? ] must-fail-with
