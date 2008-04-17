USING: kernel tools.test io.encodings.utf16 arrays sbufs
io.streams.byte-array sequences io.encodings io unicode
io.encodings.string alien.c-types accessors classes ;
IN: io.encodings.utf16.tests

[ { CHAR: x } ] [ { 0 CHAR: x } utf16be decode >array ] unit-test
[ { HEX: 1D11E } ] [ { HEX: D8 HEX: 34 HEX: DD HEX: 1E } utf16be decode >array ] unit-test
[ { CHAR: replacement-character } ] [ { BIN: 11011111 CHAR: q } utf16be decode >array ] unit-test
[ { CHAR: replacement-character } ] [ { BIN: 11011011 CHAR: x BIN: 11011011 CHAR: x } utf16be decode >array ] unit-test

[ { 0 120 216 52 221 30 } ] [ { CHAR: x HEX: 1d11e } utf16be encode >array ] unit-test

[ { CHAR: x } ] [ { CHAR: x 0 } utf16le decode >array ] unit-test
[ { 119070 } ] [ { HEX: 34 HEX: D8 HEX: 1E HEX: DD } utf16le decode >array ] unit-test
[ { CHAR: replacement-character } ] [ { 0 BIN: 11011111 } utf16le decode >array ] unit-test
[ { CHAR: replacement-character } ] [ { 0 BIN: 11011011 0 0 } utf16le decode >array ] unit-test
[ { 119070 } ] [ { HEX: 34 HEX: D8 HEX: 1E HEX: DD } utf16le decode >array ] unit-test

[ { 120 0 52 216 30 221 } ] [ { CHAR: x HEX: 1d11e } utf16le encode >array ] unit-test

[ { CHAR: x } ] [ { HEX: ff HEX: fe CHAR: x 0 } utf16 decode >array ] unit-test
[ { CHAR: x } ] [ { HEX: fe HEX: ff 0 CHAR: x } utf16 decode >array ] unit-test

[ { HEX: ff HEX: fe 120 0 52 216 30 221 } ] [ { CHAR: x HEX: 1d11e } utf16 encode >array ] unit-test

: correct-endian
    code>> class little-endian? [ utf16le = ] [ utf16be = ] if ;

[ t ] [ B{ } utf16n <byte-reader> correct-endian ] unit-test
[ t ] [ utf16n <byte-writer> correct-endian ] unit-test
