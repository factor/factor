! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel tools.test io.encodings.utf32 arrays sbufs
io.streams.byte-array sequences io.encodings io strings
io.encodings.string alien.c-types alien.strings accessors classes ;
IN: io.encodings.utf32.tests

[ { CHAR: x } ] [ B{ 0 0 0 CHAR: x } utf32be decode >array ] unit-test
[ { HEX: 1D11E } ] [ B{ 0 1 HEX: D1 HEX: 1E } utf32be decode >array ] unit-test
[ { CHAR: replacement-character } ] [ B{ 0 1 HEX: D1 } utf32be decode >array ] unit-test
[ { CHAR: replacement-character } ] [ B{ 0 1 } utf32be decode >array ] unit-test
[ { CHAR: replacement-character } ] [ B{ 0 } utf32be decode >array ] unit-test
[ { } ] [ { } utf32be decode >array ] unit-test

[ { 0 0 0 CHAR: x 0 1 HEX: D1 HEX: 1E } ] [ { CHAR: x HEX: 1d11e } >string utf32be encode >array ] unit-test

[ { CHAR: x } ] [ B{ CHAR: x 0 0 0 } utf32le decode >array ] unit-test
[ { HEX: 1d11e } ] [ B{ HEX: 1e HEX: d1 1 0 } utf32le decode >array ] unit-test
[ { CHAR: replacement-character } ] [ B{ HEX: 1e HEX: d1 1 } utf32le decode >array ] unit-test
[ { CHAR: replacement-character } ] [ B{ HEX: 1e HEX: d1 } utf32le decode >array ] unit-test
[ { CHAR: replacement-character } ] [ B{ HEX: 1e } utf32le decode >array ] unit-test
[ { } ] [ { } utf32le decode >array ] unit-test

[ { 120 0 0 0 HEX: 1e HEX: d1 1 0 } ] [ { CHAR: x HEX: 1d11e } >string utf32le encode >array ] unit-test

[ { CHAR: x } ] [ B{ HEX: ff HEX: fe 0 0 CHAR: x 0 0 0 } utf32 decode >array ] unit-test
[ { CHAR: x } ] [ B{ 0 0 HEX: fe HEX: ff 0 0 0 CHAR: x } utf32 decode >array ] unit-test

[ { HEX: ff HEX: fe 0 0 120 0 0 0 HEX: 1e HEX: d1 1 0 } ] [ { CHAR: x HEX: 1d11e } >string utf32 encode >array ] unit-test

