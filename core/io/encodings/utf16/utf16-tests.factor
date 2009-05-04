! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel tools.test io.encodings.utf16 arrays sbufs
io.streams.byte-array sequences io.encodings io strings
io.encodings.string alien.c-types alien.strings accessors classes ;
IN: io.encodings.utf16.tests

[ { CHAR: x } ] [ B{ 0 CHAR: x } utf16be decode >array ] unit-test
[ { HEX: 1D11E } ] [ B{ HEX: D8 HEX: 34 HEX: DD HEX: 1E } utf16be decode >array ] unit-test
[ { CHAR: replacement-character } ] [ B{ BIN: 11011111 CHAR: q } utf16be decode >array ] unit-test
[ { CHAR: replacement-character } ] [ B{ BIN: 11011011 CHAR: x BIN: 11011011 CHAR: x } utf16be decode >array ] unit-test

[ { 0 120 216 52 221 30 } ] [ { CHAR: x HEX: 1d11e } >string utf16be encode >array ] unit-test

[ { CHAR: x } ] [ B{ CHAR: x 0 } utf16le decode >array ] unit-test
[ { 119070 } ] [ B{ HEX: 34 HEX: D8 HEX: 1E HEX: DD } >string utf16le decode >array ] unit-test
[ { CHAR: replacement-character } ] [ { 0 BIN: 11011111 } >string utf16le decode >array ] unit-test
[ { CHAR: replacement-character } ] [ { 0 BIN: 11011011 0 0 } >string utf16le decode >array ] unit-test

[ { 120 0 52 216 30 221 } ] [ { CHAR: x HEX: 1d11e } >string utf16le encode >array ] unit-test

[ { CHAR: x } ] [ B{ HEX: ff HEX: fe CHAR: x 0 } utf16 decode >array ] unit-test
[ { CHAR: x } ] [ B{ HEX: fe HEX: ff 0 CHAR: x } utf16 decode >array ] unit-test

[ { HEX: ff HEX: fe 120 0 52 216 30 221 } ] [ { CHAR: x HEX: 1d11e } >string utf16 encode >array ] unit-test
