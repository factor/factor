! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings.string io.encodings.iso2022 tools.test
io.encodings.iso2022.private literals strings byte-arrays ;
IN: io.encodings.iso2022

[ "hello" ] [ "hello" >byte-array iso2022 decode ] unit-test
[ "hello" ] [ "hello" iso2022 encode >string ] unit-test

[ "hi" ] [ B{ CHAR: h ESC CHAR: ( CHAR: B CHAR: i } iso2022 decode ] unit-test
[ "hi" ] [ B{ CHAR: h CHAR: i ESC CHAR: ( CHAR: B } iso2022 decode ] unit-test
[ "hi\u00fffd" ] [ B{ CHAR: h CHAR: i ESC CHAR: ( } iso2022 decode ] unit-test
[ "hi\u00fffd" ] [ B{ CHAR: h CHAR: i ESC } iso2022 decode ] unit-test

[ B{ CHAR: h ESC CHAR: ( CHAR: J HEX: D8 } ] [ "h\u00ff98" iso2022 encode ] unit-test
[ "h\u00ff98" ] [ B{ CHAR: h ESC CHAR: ( CHAR: J HEX: D8 } iso2022 decode ] unit-test
[ "hi" ] [ B{ CHAR: h ESC CHAR: ( CHAR: J CHAR: i } iso2022 decode ] unit-test
[ "h" ] [ B{ CHAR: h ESC CHAR: ( CHAR: J } iso2022 decode ] unit-test
[ "h\u00fffd" ] [ B{ CHAR: h ESC CHAR: ( CHAR: J HEX: 80 } iso2022 decode ] unit-test

[ B{ CHAR: h ESC CHAR: $ CHAR: B HEX: 3E HEX: 47 } ] [ "h\u007126" iso2022 encode ] unit-test
[ "h\u007126" ] [ B{ CHAR: h ESC CHAR: $ CHAR: B HEX: 3E HEX: 47 } iso2022 decode ] unit-test
[ "h\u00fffd" ] [ B{ CHAR: h ESC CHAR: $ CHAR: B HEX: 3E } iso2022 decode ] unit-test
[ "h" ] [ B{ CHAR: h ESC CHAR: $ CHAR: B } iso2022 decode ] unit-test
[ "h\u00fffd" ] [ B{ CHAR: h ESC CHAR: $ } iso2022 decode ] unit-test
[ "h\u00fffd" ] [ B{ CHAR: h ESC } iso2022 decode ] unit-test
[ "h\u00fffd" ] [ B{ CHAR: h ESC CHAR: $ CHAR: B HEX: 80 HEX: 80 } iso2022 decode ] unit-test

[ B{ CHAR: h ESC CHAR: $ CHAR: ( CHAR: D HEX: 38 HEX: 54 } ] [ "h\u0058ce" iso2022 encode ] unit-test
[ "h\u0058ce" ] [ B{ CHAR: h ESC CHAR: $ CHAR: ( CHAR: D HEX: 38 HEX: 54 } iso2022 decode ] unit-test
[ "h\u00fffd" ] [ B{ CHAR: h ESC CHAR: $ CHAR: ( CHAR: D HEX: 38 } iso2022 decode ] unit-test
[ "h" ] [ B{ CHAR: h ESC CHAR: $ CHAR: ( CHAR: D } iso2022 decode ] unit-test
[ "h\u00fffd" ] [ B{ CHAR: h ESC CHAR: $ CHAR: ( } iso2022 decode ] unit-test
[ "h\u00fffd" ] [ B{ CHAR: h ESC CHAR: $ CHAR: ( CHAR: D HEX: 70 HEX: 70 } iso2022 decode ] unit-test

[ "\u{syriac-music}" iso2022 encode ] must-fail
