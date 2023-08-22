! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: io.encodings.gb18030 io.encodings.string strings tools.test arrays ;

{ "hello" } [ "hello" gb18030 encode >string ] unit-test
{ "hello" } [ "hello" gb18030 decode ] unit-test
{ B{ 0xA1 0xA4 0x81 0x30 0x86 0x30 } }
[ B{ 0xB7 0xB8 } >string gb18030 encode ] unit-test
{ { 0xB7 0xB8 } }
[ B{ 0xA1 0xA4 0x81 0x30 0x86 0x30 } gb18030 decode >array ] unit-test
{ { 0xB7 CHAR: replacement-character } }
[ B{ 0xA1 0xA4 0x81 0x30 0x86 } gb18030 decode >array ] unit-test
{ { 0xB7 CHAR: replacement-character } }
[ B{ 0xA1 0xA4 0x81 0x30 } gb18030 decode >array ] unit-test
{ { 0xB7 CHAR: replacement-character } }
[ B{ 0xA1 0xA4 0x81 } gb18030 decode >array ] unit-test
{ { 0xB7 } }
[ B{ 0xA1 0xA4 } gb18030 decode >array ] unit-test
{ { CHAR: replacement-character } }
[ B{ 0xA1 } >string gb18030 decode >array ] unit-test
{ { 0x44D7 0x464B } }
[ B{ 0x82 0x33 0xA3 0x39 0x82 0x33 0xC9 0x31 }
  gb18030 decode >array ] unit-test
{ { 0x82 0x33 0xA3 0x39 0x82 0x33 0xC9 0x31 } }
[ { 0x44D7 0x464B } >string gb18030 encode >array ] unit-test
