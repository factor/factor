! Copyright (C) 2019 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors endian kernel math namespaces sequences
strings tools.test ulid ulid.private ;
IN: ulid.tests

{ "0123456789ABCDEFGH1JK1MN0PQRSTUVWXYZ" }
[ "0123456789abcdefghijklmnopqrstuvwxyz" normalize-ulid ] unit-test

{ "ABCDEFGH1JK1MN0PQRSTUVWXYZ" }
[ "ABCDEFGHIJKLMNOPQRSTUVWXYZ" normalize-ulid ] unit-test

[ "aoeu" ulid>bytes ] [
    [ ulid>bytes-bad-length? ] keep n>> 4 = and
] must-fail-with

[ "aBCDEFGH1JK1MN0PQRSTUVWXYZ" ulid>bytes ] [
    [ ulid>bytes-bad-character? ] keep ch>> CHAR: a = and
] must-fail-with

[ "ABCDEFGH1JK1MN0PQRSTUVWXYZ" ulid>bytes ] [
    [ ulid>bytes-bad-character? ] keep ch>> CHAR: U = and
] must-fail-with

[ "ABCDEFGH1JK1MN0PQRST0VWXYZ" ulid>bytes ]
[ ulid>bytes-overflow? ] must-fail-with

{ B{ 235 99 92 248 68 50 152 105 80 90 248 206 129 190 119 223 } }
[ "7BCDEFGH1JK1MN0PQRST0VWXYZ" ulid>bytes ] unit-test

{ "7BCDEFGH1JK1MN0PQRST0VWXYZ" }
[ B{ 235 99 92 248 68 50 152 105 80 90 248 206 129 190 119 223 } bytes>ulid ] unit-test

[ B{ 235 99 92 248 68 50 152 105 80 90 248 206 129 190 119 } bytes>ulid ] [
    [ bytes>ulid-bad-length? ] keep n>> 15 = and
] must-fail-with

{ t } [ ulid string? ] unit-test
{ 26 } [ ulid length ] unit-test
{ f } [ ulid ulid = ] unit-test

: ulid-less-than-80-bits ( -- ulid )
    ulid last-random-bits get 80-bits >=
    [ drop ulid-less-than-80-bits ] when ;

{ t } [
    ulid-less-than-80-bits t (ulid) [ ulid>bytes be> ] bi@ 1 - =
] unit-test

[ 80-bits \ last-random-bits set t (ulid) ]
[ ulid-overflow? ] must-fail-with
