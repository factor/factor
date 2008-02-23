USING: kernel tools.test io.encodings.utf16 arrays sbufs sequences io.encodings
io unicode ;

: decode-w/stream ( array encoding -- newarray )
    >r >sbuf dup reverse-here r> <decoded> contents >array ;

: encode-w/stream ( array encoding -- newarray )
    >r SBUF" " clone tuck r> <encoded> stream-write >array ;

[ { CHAR: x } ] [ { 0 CHAR: x } utf16be decode-w/stream ] unit-test
[ { HEX: 1D11E } ] [ { HEX: D8 HEX: 34 HEX: DD HEX: 1E } utf16be decode-w/stream ] unit-test
[ { CHAR: replacement-character } ] [ { BIN: 11011111 CHAR: q } utf16be decode-w/stream ] unit-test
[ { CHAR: replacement-character } ] [ { BIN: 11011011 CHAR: x BIN: 11011011 CHAR: x } utf16be decode-w/stream ] unit-test

[ { 0 120 216 52 221 30 } ] [ { CHAR: x HEX: 1d11e } utf16be encode-w/stream ] unit-test

[ { CHAR: x } ] [ { CHAR: x 0 } utf16le decode-w/stream ] unit-test
[ { 119070 } ] [ { HEX: 34 HEX: D8 HEX: 1E HEX: DD } utf16le decode-w/stream ] unit-test
[ { CHAR: replacement-character } ] [ { 0 BIN: 11011111 } utf16le decode-w/stream ] unit-test
[ { CHAR: replacement-character } ] [ { 0 BIN: 11011011 0 0 } utf16le decode-w/stream ] unit-test
[ { 119070 } ] [ { HEX: 34 HEX: D8 HEX: 1E HEX: DD } utf16le decode-w/stream ] unit-test

[ { 120 0 52 216 30 221 } ] [ { CHAR: x HEX: 1d11e } utf16le encode-w/stream ] unit-test

[ { CHAR: x } ] [ { HEX: ff HEX: fe CHAR: x 0 } utf16 decode-w/stream ] unit-test
[ { CHAR: x } ] [ { HEX: fe HEX: ff 0 CHAR: x } utf16 decode-w/stream ] unit-test

[ { HEX: ff HEX: fe 120 0 52 216 30 221 } ] [ { CHAR: x HEX: 1d11e } utf16 encode-w/stream ] unit-test
