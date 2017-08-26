! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings.string io.encodings.iso2022 tools.test
io.encodings.iso2022.private literals strings byte-arrays ;
IN: io.encodings.iso2022

{ "hello" } [ "hello" >byte-array iso2022 decode ] unit-test
{ "hello" } [ "hello" iso2022 encode >string ] unit-test

{ "hi" } [ B{ char: h $ ESC char: \( char: B char: i } iso2022 decode ] unit-test
{ "hi" } [ B{ char: h char: i $ ESC char: \( char: B } iso2022 decode ] unit-test
{ "hi\u00fffd" } [ B{ char: h char: i $ ESC char: \( } iso2022 decode ] unit-test
{ "hi\u00fffd" } [ B{ char: h char: i $ ESC } iso2022 decode ] unit-test

{ B{ char: h $ ESC char: \( char: J 0xD8 } } [ "h\u00ff98" iso2022 encode ] unit-test
{ "h\u00ff98" } [ B{ char: h $ ESC char: \( char: J 0xD8 } iso2022 decode ] unit-test
{ "hi" } [ B{ char: h $ ESC char: \( char: J char: i } iso2022 decode ] unit-test
{ "h" } [ B{ char: h $ ESC char: \( char: J } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ char: h $ ESC char: \( char: J 0x80 } iso2022 decode ] unit-test

{ B{ char: h $ ESC char: $ char: B 0x3E 0x47 } } [ "h\u007126" iso2022 encode ] unit-test
{ "h\u007126" } [ B{ char: h $ ESC char: $ char: B 0x3E 0x47 } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ char: h $ ESC char: $ char: B 0x3E } iso2022 decode ] unit-test
{ "h" } [ B{ char: h $ ESC char: $ char: B } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ char: h $ ESC char: $ } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ char: h $ ESC } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ char: h $ ESC char: $ char: B 0x80 0x80 } iso2022 decode ] unit-test

{ B{ char: h $ ESC char: $ char: \( char: D 0x38 0x54 } } [ "h\u0058ce" iso2022 encode ] unit-test
{ "h\u0058ce" } [ B{ char: h $ ESC char: $ char: \( char: D 0x38 0x54 } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ char: h $ ESC char: $ char: \( char: D 0x38 } iso2022 decode ] unit-test
{ "h" } [ B{ char: h $ ESC char: $ char: \( char: D } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ char: h $ ESC char: $ char: \( } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ char: h $ ESC char: $ char: \( char: D 0x70 0x70 } iso2022 decode ] unit-test

[ "\u{syriac-music}" iso2022 encode ] must-fail
