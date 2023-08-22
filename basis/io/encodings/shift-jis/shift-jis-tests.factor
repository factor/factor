! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: arrays io.encodings.shift-jis io.encodings.string strings
tools.test ;

{ { CHAR: replacement-character } } [ { 141 } shift-jis decode >array ] unit-test
{ "" } [ "" shift-jis decode >string ] unit-test
{ "" } [ "" shift-jis encode >string ] unit-test
[ { CHAR: replacement-character } shift-jis encode ] must-fail
{ "ab¥ｨ" } [ { CHAR: a CHAR: b 0x5C 0xA8 } shift-jis decode ] unit-test
{ { CHAR: a CHAR: b 0x5C 0xA8 } } [ "ab¥ｨ" shift-jis encode >array ] unit-test
{ "ab\\ｨ" } [ { CHAR: a CHAR: b 0x5C 0xA8 } windows-31j decode ] unit-test
{ { CHAR: a CHAR: b 0x5C 0xA8 } } [ "ab\\ｨ" windows-31j encode >array ] unit-test
{ "\u000081\u0000c8" } [ CHAR: logical-and 1string windows-31j encode >string ] unit-test
{ "\u000081\u0000c8" } [ CHAR: logical-and 1string shift-jis encode >string ] unit-test
{ { CHAR: logical-and } } [ "\u000081\u0000c8" windows-31j decode >array ] unit-test
{ { CHAR: logical-and } } [ "\u000081\u0000c8" shift-jis decode >array ] unit-test
