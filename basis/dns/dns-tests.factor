! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test dns ;
IN: dns.tests

{ B{ 0 } } [ "" >name ] unit-test
{ B{ 0 } } [ "." >name ] unit-test
{ B{ 3 99 111 109 0 } } [ "com." >name ] unit-test
{ B{ 1 49 1 49 1 49 1 49 0 } } [ "1.1.1.1." >name ] unit-test

! "1.1.1.1" reverse-ipv4-lookup
! "one.one.one.one" A IN dns-query

