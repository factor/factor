! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays io.encodings.string io.encodings.utf16 strings
tools.test ;

{ { ch'x } } [ B{ 0 ch'x } utf16be decode >array ] unit-test
{ { 0x1D11E } } [ B{ 0xD8 0x34 0xDD 0x1E } utf16be decode >array ] unit-test
{ { ch'replacement-character } } [ B{ 0b11011111 ch'q } utf16be decode >array ] unit-test
{ { ch'replacement-character } } [ B{ 0b11011011 ch'x 0b11011011 ch'x } utf16be decode >array ] unit-test

{ { 0 120 216 52 221 30 } } [ { ch'x 0x1d11e } >string utf16be encode >array ] unit-test

{ { ch'x } } [ B{ ch'x 0 } utf16le decode >array ] unit-test
{ { 119070 } } [ B{ 0x34 0xD8 0x1E 0xDD } >string utf16le decode >array ] unit-test
{ { ch'replacement-character } } [ { 0 0b11011111 } >string utf16le decode >array ] unit-test
{ { ch'replacement-character } } [ { 0 0b11011011 0 0 } >string utf16le decode >array ] unit-test

{ { 120 0 52 216 30 221 } } [ { ch'x 0x1d11e } >string utf16le encode >array ] unit-test

{ { ch'x } } [ B{ 0xff 0xfe ch'x 0 } utf16 decode >array ] unit-test
{ { ch'x } } [ B{ 0xfe 0xff 0 ch'x } utf16 decode >array ] unit-test

{ { 0xff 0xfe 120 0 52 216 30 221 } } [ { ch'x 0x1d11e } >string utf16 encode >array ] unit-test

! test ascii encoding path

{ B{ ch'a 0 ch'b 0 ch'c 0 } } [ "abc" utf16le encode ] unit-test
{ B{ 0 ch'a 0 ch'b 0 ch'c } } [ "abc" utf16be encode ] unit-test
