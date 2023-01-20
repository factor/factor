! Copyright (C) 2019 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: math math.parser random.passwords sequences tools.test ;
IN: random.passwords.tests

{ "aaaaaaaaaa" } [ 10 "a" password ] unit-test
{ 10 } [ 10 "ab" password length ] unit-test
{ "" } [ 0 "ab" password ] unit-test
[ -1 "ab" password ] must-fail

{ 2 } [ 2 ascii-password length ] unit-test
{ 3 } [ 3 alnum-password length ] unit-test
{ 4 } [ 4 hex-password length ] unit-test
{ t } [ 4 hex-password hex> 65535 <= ] unit-test
