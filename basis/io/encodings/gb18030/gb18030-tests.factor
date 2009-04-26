! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings.gb18030 io.encodings.string strings tools.test arrays ;
IN: io.encodings.gb18030.tests

[ "hello" ] [ "hello" gb18030 encode >string ] unit-test
[ "hello" ] [ "hello" gb18030 decode ] unit-test
[ B{ HEX: A1 HEX: A4 HEX: 81 HEX: 30 HEX: 86 HEX: 30 } ]
[ B{ HEX: B7 HEX: B8 } >string gb18030 encode ] unit-test
[ { HEX: B7 HEX: B8 } ]
[ B{ HEX: A1 HEX: A4 HEX: 81 HEX: 30 HEX: 86 HEX: 30 } gb18030 decode >array ] unit-test
[ { HEX: B7 CHAR: replacement-character } ]
[ B{ HEX: A1 HEX: A4 HEX: 81 HEX: 30 HEX: 86 } gb18030 decode >array ] unit-test
[ { HEX: B7 CHAR: replacement-character } ]
[ B{ HEX: A1 HEX: A4 HEX: 81 HEX: 30 } gb18030 decode >array ] unit-test
[ { HEX: B7 CHAR: replacement-character } ]
[ B{ HEX: A1 HEX: A4 HEX: 81 } gb18030 decode >array ] unit-test
[ { HEX: B7 } ]
[ B{ HEX: A1 HEX: A4 } gb18030 decode >array ] unit-test
[ { CHAR: replacement-character } ]
[ B{ HEX: A1 } >string gb18030 decode >array ] unit-test
[ { HEX: 44D7 HEX: 464B } ]
[ B{ HEX: 82 HEX: 33 HEX: A3 HEX: 39 HEX: 82 HEX: 33 HEX: C9 HEX: 31 }
  gb18030 decode >array ] unit-test
[ { HEX: 82 HEX: 33 HEX: A3 HEX: 39 HEX: 82 HEX: 33 HEX: C9 HEX: 31 } ]
[ { HEX: 44D7 HEX: 464B } >string gb18030 encode >array ] unit-test
