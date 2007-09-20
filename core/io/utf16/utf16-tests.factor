USING: tools.test io.utf16 ;

[ { CHAR: x } ] [ { 0 CHAR: x } decode-utf16be ] unit-test
[ { HEX: 1D11E } ] [ { HEX: D8 HEX: 34 HEX: DD HEX: 1E } decode-utf16be ] unit-test
[ { BIN: 11011111 CHAR: q } decode-utf16be ] unit-test-fails
[ { BIN: 11011011 CHAR: x BIN: 11011011 CHAR: x } decode-utf16be ] unit-test-fails

[ B{ 0 120 216 52 221 30 } ] [ { CHAR: x HEX: 1d11e } encode-utf16be ] unit-test

[ { CHAR: x } ] [ { CHAR: x 0 } decode-utf16le ] unit-test
[ { 119070 } ] [ { HEX: 34 HEX: D8 HEX: 1E HEX: DD } decode-utf16le ] unit-test
[ { 0 BIN: 11011111 } decode-utf16le ] unit-test-fails
[ { 0 BIN: 11011011 0 0 } decode-utf16le ] unit-test-fails

[ B{ 120 0 52 216 30 221 } ] [ { CHAR: x HEX: 1d11e } encode-utf16le ] unit-test
