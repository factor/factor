! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays io.encodings.iso2022
io.encodings.iso2022.private io.encodings.string literals
strings tools.test ;

{ "hello" } [ "hello" >byte-array iso2022 decode ] unit-test
{ "hello" } [ "hello" iso2022 encode >string ] unit-test

{ "hi" } [ B{ CHAR: h $ ESC CHAR: ( CHAR: B CHAR: i } iso2022 decode ] unit-test
{ "hi" } [ B{ CHAR: h CHAR: i $ ESC CHAR: ( CHAR: B } iso2022 decode ] unit-test
{ "hi\u00fffd" } [ B{ CHAR: h CHAR: i $ ESC CHAR: ( } iso2022 decode ] unit-test
{ "hi\u00fffd" } [ B{ CHAR: h CHAR: i $ ESC } iso2022 decode ] unit-test

{ B{ CHAR: h $ ESC CHAR: ( CHAR: J 0xD8 } } [ "h\u00ff98" iso2022 encode ] unit-test
{ "h\u00ff98" } [ B{ CHAR: h $ ESC CHAR: ( CHAR: J 0xD8 } iso2022 decode ] unit-test
{ "hi" } [ B{ CHAR: h $ ESC CHAR: ( CHAR: J CHAR: i } iso2022 decode ] unit-test
{ "h" } [ B{ CHAR: h $ ESC CHAR: ( CHAR: J } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ CHAR: h $ ESC CHAR: ( CHAR: J 0x80 } iso2022 decode ] unit-test

{ B{ CHAR: h $ ESC CHAR: $ CHAR: B 0x3E 0x47 } } [ "h\u007126" iso2022 encode ] unit-test
{ "h\u007126" } [ B{ CHAR: h $ ESC CHAR: $ CHAR: B 0x3E 0x47 } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ CHAR: h $ ESC CHAR: $ CHAR: B 0x3E } iso2022 decode ] unit-test
{ "h" } [ B{ CHAR: h $ ESC CHAR: $ CHAR: B } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ CHAR: h $ ESC CHAR: $ } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ CHAR: h $ ESC } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ CHAR: h $ ESC CHAR: $ CHAR: B 0x80 0x80 } iso2022 decode ] unit-test

{ B{ CHAR: h $ ESC CHAR: $ CHAR: ( CHAR: D 0x38 0x54 } } [ "h\u0058ce" iso2022 encode ] unit-test
{ "h\u0058ce" } [ B{ CHAR: h $ ESC CHAR: $ CHAR: ( CHAR: D 0x38 0x54 } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ CHAR: h $ ESC CHAR: $ CHAR: ( CHAR: D 0x38 } iso2022 decode ] unit-test
{ "h" } [ B{ CHAR: h $ ESC CHAR: $ CHAR: ( CHAR: D } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ CHAR: h $ ESC CHAR: $ CHAR: ( } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ CHAR: h $ ESC CHAR: $ CHAR: ( CHAR: D 0x70 0x70 } iso2022 decode ] unit-test

[ "\u{syriac-music}" iso2022 encode ] must-fail
