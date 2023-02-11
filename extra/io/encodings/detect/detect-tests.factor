! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays io.encodings.8-bit io.encodings.binary
io.encodings.detect io.encodings.latin1 io.encodings.utf16
io.encodings.utf32 io.encodings.utf8 namespaces tools.test ;

! UTF encodings with BOMs
{ utf16be } [ B{ 0xFE 0xFF 0x00 0x31 0x00 0x32 0x00 0x33 } detect-byte-array ] unit-test
{ utf16le } [ B{ 0xFF 0xFE 0x31 0x00 0x32 0x00 0x33 0x00 } detect-byte-array ] unit-test
{ utf32be } [ B{ 0x00 0x00 0xFE 0xFF 0x00 0x00 0x00 0x31 0x00 0x00 0x00 0x32 0x00 0x00 0x00 0x33 } detect-byte-array ] unit-test
{ utf32le } [ B{ 0xFF 0xFE 0x00 0x00 0x31 0x00 0x00 0x00 0x32 0x00 0x00 0x00 0x33 0x00 0x00 0x00 } detect-byte-array ] unit-test
{ utf8 } [ B{ 0xEF 0xBB 0xBF 0x31 0x32 0x33 } detect-byte-array ] unit-test

! XML prolog
{ utf8 }
[ "<?xml version=\"1.0\"?>" >byte-array detect-byte-array ]
unit-test

{ utf8 }
[ "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >byte-array detect-byte-array ]
unit-test

{ latin1 }
[ "<?xml version='1.0' encoding='ISO-8859-1'?>" >byte-array detect-byte-array ]
unit-test

{ latin1 }
[ "<?xml version='1.0' encoding=\"ISO-8859-1\" " >byte-array detect-byte-array ]
unit-test

! Default to utf8 if decoding succeeds and there are no nulls
{ utf8 } [ B{ } detect-byte-array ] unit-test
{ utf8 } [ B{ 0x31 0x32 0x33 } detect-byte-array ] unit-test
{ utf8 } [ B{ 0x31 0x32 0xC2 0xA0 0x33 } detect-byte-array ] unit-test
{ latin1 } [ B{ 0x31 0x32 0xA0 0x33 } detect-byte-array ] unit-test
{ koi8-r } [
    koi8-r default-encoding [
        B{ 0x31 0x32 0xA0 0x33 } detect-byte-array
    ] with-variable
] unit-test

{ binary } [ B{ 0x31 0x32 0x33 0xC2 0xA0 0x00 } detect-byte-array ] unit-test
{ binary } [ B{ 0x31 0x32 0x33 0xC2 0xA0 0x00 0x30 } detect-byte-array ] unit-test
