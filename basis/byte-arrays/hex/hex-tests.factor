! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test byte-arrays.hex eval ;
IN: byte-arrays.hex.tests

{ B{ 16 0 8 0 } } [ HEX{ 10 00 08 00 } ] unit-test
{ B{ 255 255 15 255 255 255 } } [ HEX{ ffff 0fff ffff } ] unit-test

[ "HEX{ ffff fff ffff }" parse-string ] must-fail
[ "HEX{ 10 00 08 0 }" parse-string ] must-fail
[ "HEX{ 1 00 00 80 }" parse-string ] must-fail
