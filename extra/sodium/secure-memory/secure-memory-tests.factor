! Copyright (C) 2020 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.data byte-arrays destructors kernel literals
namespaces sequences sodium.ffi sodium.secure-memory tools.test ;
IN: sodium.secure-memory.tests

SYMBOLS: test-mem test-cloned ;

: =uninit? ( secure-memory -- ? )
    binary-object memory>byte-array
    crypto_auth_hmacsha512_KEYBYTES 0xdb <repetition> >byte-array = ;

{ $ crypto_auth_hmacsha512_KEYBYTES } [
    crypto_auth_hmacsha512_KEYBYTES new-secure-memory dup test-mem set-global
    size>>
] unit-test

{ t } [ test-mem get-global =uninit? ] unit-test
[ test-mem get-global dup allow-no-access clone ] must-fail
[ test-mem get-global >c-ptr crypto_auth_hmacsha512_keygen ] must-fail

! Write a random key to test-mem.
{ } [
    test-mem get-global [
        >c-ptr crypto_auth_hmacsha512_keygen
    ] with-write-access
] unit-test

! Clone the test-mem into test-cloned.
{ $ crypto_auth_hmacsha512_KEYBYTES } [
    test-mem get-global [
        clone dup test-cloned set-global size>>
    ] with-read-access
] unit-test

[ test-mem get-global =uninit? ] must-fail
{ f } [ test-cloned get-global =uninit? ] unit-test
{ f } [ test-mem get-global [ =uninit? ] with-read-access ] unit-test

! Contents of test-mem and test-cloned must match. test-cloned must have write
! access after cloning.
{ t } [
    test-mem get-global [
        test-cloned get-global secure-memory=
    ] with-read-access
] unit-test

! Write a new random key to test-cloned. After that the contents of test-mem and
! test-cloned must no longer match.
{ f } [
    test-cloned get-global dup >c-ptr crypto_auth_hmacsha512_keygen
    test-mem get-global [ secure-memory= ] with-read-access
] unit-test

{ f f } [
    test-cloned [ dup dispose [ size>> ] [ >c-ptr ] bi f ] change-global
] unit-test

[ test-mem [ dup dispose f ] change-global clone ]
[ already-disposed? ] must-fail-with
