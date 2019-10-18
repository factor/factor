USING: test utf16 utf8 ;

[ T{ new f } { CHAR: x } ] [ <new> { 0 CHAR: x } utf16be ] unit-test
[ T{ new f } { HEX: 1D11E } ] [ <new> { HEX: D8 HEX: 34 HEX: DD HEX: 1E } utf16be ] unit-test
[ T{ new f } { CHAR: ? } ] [ <new> { BIN: 11011111 CHAR: q } utf16be ] unit-test
[ T{ new f } { CHAR: ? } ] [ <new> { BIN: 11011011 CHAR: x BIN: 11011011 CHAR: x } utf16be ] unit-test

[ { 0 120 216 52 221 30 } ] [ { CHAR: x HEX: 1d11e } string>utf16be ] unit-test

[ T{ new f } { CHAR: x } ] [ <new> { CHAR: x 0 } utf16le ] unit-test
[ T{ new f } { 119070 } ] [ <new> { HEX: 34 HEX: D8 HEX: 1E HEX: DD } utf16le ] unit-test
[ T{ new f } { CHAR: ? } ] [ <new> { 0 BIN: 11011111 } utf16le ] unit-test
[ T{ new f } { CHAR: ? } ] [ <new> { 0 BIN: 11011011 0 0 } utf16le ] unit-test

[ { 120 0 52 216 30 221 } ] [ { CHAR: x HEX: 1d11e } string>utf16le ] unit-test
