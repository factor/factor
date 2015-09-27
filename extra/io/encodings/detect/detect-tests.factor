! (c)2010 Joe Groff bsd license
USING: byte-arrays byte-arrays.hex io.encodings.8-bit.koi8-r
io.encodings.8-bit.latin1 io.encodings.binary
io.encodings.detect io.encodings.utf16 io.encodings.utf32
io.encodings.utf8 namespaces tools.test ;
IN: io.encodings.detect.tests

! UTF encodings with BOMs
{ utf16be } [ HEX{ FEFF 0031 0032 0033 } detect-byte-array ] unit-test
{ utf16le } [ HEX{ FFFE 3100 3200 3300 } detect-byte-array ] unit-test
{ utf32be } [ HEX{ 0000FEFF 00000031 00000032 00000033 } detect-byte-array ] unit-test
{ utf32le } [ HEX{ FFFE0000 31000000 32000000 33000000 } detect-byte-array ] unit-test
{ utf8 } [ HEX{ EF BB BF 31 32 33 } detect-byte-array ] unit-test

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
{ utf8 } [ HEX{ } detect-byte-array ] unit-test
{ utf8 } [ HEX{ 31 32 33 } detect-byte-array ] unit-test
{ utf8 } [ HEX{ 31 32 C2 A0 33 } detect-byte-array ] unit-test
{ latin1 } [ HEX{ 31 32 A0 33 } detect-byte-array ] unit-test
{ koi8-r } [
    koi8-r default-8bit-encoding [
        HEX{ 31 32 A0 33 } detect-byte-array
    ] with-variable
] unit-test

{ binary } [ HEX{ 31 32 33 C2 A0 00 } detect-byte-array ] unit-test
{ binary } [ HEX{ 31 32 33 C2 A0 00 30 } detect-byte-array ] unit-test
