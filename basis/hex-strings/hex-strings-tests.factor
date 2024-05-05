! Copyright (C) 2024 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: hex-strings tools.test ;
IN: hex-strings.tests

{ "deadbeef" } [ B{ 222 173 190 239 } bytes>hex-string ] unit-test
{ B{ 222 173 190 239 } } [ "deADbeEF" hex-string>bytes ] unit-test
[ "0" hex-string>bytes ] [ invalid-hex-string-length? ] must-fail-with

{ f } [ "asdf" hex-string? ] unit-test
{ t } [ "adfAE12309812861cdef" hex-string? ] unit-test
{ t } [ "" hex-string? ] unit-test
{ t } [ f hex-string? ] unit-test
