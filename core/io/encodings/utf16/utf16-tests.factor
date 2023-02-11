! Copyright (C) 2008 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data arrays io.encodings.string
io.encodings.utf16 io.streams.byte-array kernel strings
tools.test ;
IN: io.encodings.utf16.tests

{ { CHAR: x } } [ B{ 0 CHAR: x } utf16be decode >array ] unit-test
{ { 0x1D11E } } [ B{ 0xD8 0x34 0xDD 0x1E } utf16be decode >array ] unit-test
{ { CHAR: replacement-character } } [ B{ 0b11011111 CHAR: q } utf16be decode >array ] unit-test
{ { CHAR: replacement-character } } [ B{ 0b11011011 CHAR: x 0b11011011 CHAR: x } utf16be decode >array ] unit-test

{ { 0 120 216 52 221 30 } } [ { CHAR: x 0x1d11e } >string utf16be encode >array ] unit-test

{ { CHAR: x } } [ B{ CHAR: x 0 } utf16le decode >array ] unit-test
{ { 119070 } } [ B{ 0x34 0xD8 0x1E 0xDD } >string utf16le decode >array ] unit-test
{ { CHAR: replacement-character } } [ { 0 0b11011111 } >string utf16le decode >array ] unit-test
{ { CHAR: replacement-character } } [ { 0 0b11011011 0 0 } >string utf16le decode >array ] unit-test

{ { 120 0 52 216 30 221 } } [ { CHAR: x 0x1d11e } >string utf16le encode >array ] unit-test

{ { CHAR: x } } [ B{ 0xff 0xfe CHAR: x 0 } utf16 decode >array ] unit-test
{ { CHAR: x } } [ B{ 0xfe 0xff 0 CHAR: x } utf16 decode >array ] unit-test

{ { 0xff 0xfe 120 0 52 216 30 221 } } [ { CHAR: x 0x1d11e } >string utf16 encode >array ] unit-test

! test ascii encoding path

{ B{ CHAR: a 0 CHAR: b 0 CHAR: c 0 } } [ "abc" utf16le encode ] unit-test
{ B{ 0 CHAR: a 0 CHAR: b 0 CHAR: c } } [ "abc" utf16be encode ] unit-test

: correct-endian ( obj -- ? )
    code>> little-endian? utf16le utf16be ? = ;

{ t } [ B{ } utf16n <byte-reader> correct-endian ] unit-test
{ t } [ utf16n <byte-writer> correct-endian ] unit-test

