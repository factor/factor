! Copyright (C) 2008 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: strings io.encodings.utf8 io.encodings.utf16
io.encodings.string tools.test io.encodings.binary ;

{ "hello" } [ "hello" utf8 decode ] unit-test
{ B{ 0 1 22 255 } } [ B{ 0 1 22 255 } binary decode ] unit-test
{ "he" } [ "\0h\0e" utf16be decode ] unit-test

{ "hello" } [ "hello" utf8 encode >string ] unit-test
{ "\0h\0e" } [ "he" utf16be encode >string ] unit-test

{ B{ 97 98 99 } } [ "abc" binary encode ] unit-test
{ B{ 97 98 99 } } [ "abc" utf8 encode ] unit-test
