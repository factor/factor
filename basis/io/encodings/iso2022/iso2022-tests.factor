! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays io.encodings.iso2022
io.encodings.iso2022.private io.encodings.string literals
strings tools.test ;

{ "hello" } [ "hello" >byte-array iso2022 decode ] unit-test
{ "hello" } [ "hello" iso2022 encode >string ] unit-test

{ "hi" } [ B{ ch'h $ ESC ch'\( ch'B ch'i } iso2022 decode ] unit-test
{ "hi" } [ B{ ch'h ch'i $ ESC ch'\( ch'B } iso2022 decode ] unit-test
{ "hi\u00fffd" } [ B{ ch'h ch'i $ ESC ch'\( } iso2022 decode ] unit-test
{ "hi\u00fffd" } [ B{ ch'h ch'i $ ESC } iso2022 decode ] unit-test

{ B{ ch'h $ ESC ch'\( ch'J 0xD8 } } [ "h\u00ff98" iso2022 encode ] unit-test
{ "h\u00ff98" } [ B{ ch'h $ ESC ch'\( ch'J 0xD8 } iso2022 decode ] unit-test
{ "hi" } [ B{ ch'h $ ESC ch'\( ch'J ch'i } iso2022 decode ] unit-test
{ "h" } [ B{ ch'h $ ESC ch'\( ch'J } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ ch'h $ ESC ch'\( ch'J 0x80 } iso2022 decode ] unit-test

{ B{ ch'h $ ESC ch'$ ch'B 0x3E 0x47 } } [ "h\u007126" iso2022 encode ] unit-test
{ "h\u007126" } [ B{ ch'h $ ESC ch'$ ch'B 0x3E 0x47 } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ ch'h $ ESC ch'$ ch'B 0x3E } iso2022 decode ] unit-test
{ "h" } [ B{ ch'h $ ESC ch'$ ch'B } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ ch'h $ ESC ch'$ } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ ch'h $ ESC } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ ch'h $ ESC ch'$ ch'B 0x80 0x80 } iso2022 decode ] unit-test

{ B{ ch'h $ ESC ch'$ ch'\( ch'D 0x38 0x54 } } [ "h\u0058ce" iso2022 encode ] unit-test
{ "h\u0058ce" } [ B{ ch'h $ ESC ch'$ ch'\( ch'D 0x38 0x54 } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ ch'h $ ESC ch'$ ch'\( ch'D 0x38 } iso2022 decode ] unit-test
{ "h" } [ B{ ch'h $ ESC ch'$ ch'\( ch'D } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ ch'h $ ESC ch'$ ch'\( } iso2022 decode ] unit-test
{ "h\u00fffd" } [ B{ ch'h $ ESC ch'$ ch'\( ch'D 0x70 0x70 } iso2022 decode ] unit-test

[ "\u{syriac-music}" iso2022 encode ] must-fail
