! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar checksums.sha tools.test totp ;
IN: totp.tests

CONSTANT: sha1-seed B{
    49 50 51 52 53 54 55 56 57 48 49 50 51 52 53 54 55 56 57 48
}
CONSTANT: sha256-seed B{
    49 50 51 52 53 54 55 56 57 48 49 50 51 52 53 54 55 56 57 48
    49 50 51 52 53 54 55 56 57 48 49 50
}
CONSTANT: sha512-seed B{
    49 50 51 52 53 54 55 56 57 48 49 50 51 52 53 54 55 56 57 48
    49 50 51 52 53 54 55 56 57 48 49 50 51 52 53 54 55 56 57 48
    49 50 51 52 53 54 55 56 57 48 49 50 51 52 53 54 55 56 57 48
    49 50 51 52
}

: test-time ( n -- totp-time )
    seconds unix-1970 time+ timestamp>count ;

{ "94287082" } [ 59 test-time sha1-seed   sha1    totp* 8 digits ] unit-test
{ "46119246" } [ 59 test-time sha256-seed sha-256 totp* 8 digits ] unit-test
! { "90693936" } [ 59 test-time sha512-seed sha-512 totp* 8 digits ] unit-test

{ "07081804" } [ 1111111109 test-time sha1-seed   sha1    totp* 8 digits ] unit-test
{ "68084774" } [ 1111111109 test-time sha256-seed sha-256 totp* 8 digits ] unit-test
! { "25091201" } [ 1111111109 test-time sha512-seed sha-512 totp* 8 digits ] unit-test

{ "14050471" } [ 1111111111 test-time sha1-seed   sha1    totp* 8 digits ] unit-test
{ "67062674" } [ 1111111111 test-time sha256-seed sha-256 totp* 8 digits ] unit-test
! { "99943326" } [ 1111111111 test-time sha512-seed sha-512 totp* 8 digits ] unit-test

{ "89005924" } [ 1234567890 test-time sha1-seed   sha1    totp* 8 digits ] unit-test
{ "91819424" } [ 1234567890 test-time sha256-seed sha-256 totp* 8 digits ] unit-test
! { "93441116" } [ 1234567890 test-time sha512-seed sha-512 totp* 8 digits ] unit-test

{ "69279037" } [ 2000000000 test-time sha1-seed   sha1    totp* 8 digits ] unit-test
{ "90698825" } [ 2000000000 test-time sha256-seed sha-256 totp* 8 digits ] unit-test
! { "38618901" } [ 2000000000 test-time sha512-seed sha-512 totp* 8 digits ] unit-test

{ "65353130" } [ 20000000000 test-time sha1-seed   sha1    totp* 8 digits ] unit-test
{ "77737706" } [ 20000000000 test-time sha256-seed sha-256 totp* 8 digits ] unit-test
! { "47863826" } [ 20000000000 test-time sha512-seed sha-512 totp* 8 digits ] unit-test
