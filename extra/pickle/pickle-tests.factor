USING: decimals kernel pickle sequences tools.test ;

[ "%." pickle> ] [ invalid-opcode? ] must-fail-with

{ null } [ "N." pickle> ] unit-test
{ null } [ "(((N." pickle> ] unit-test
{ null } [ "}N." pickle> ] unit-test

[ ".." pickle> ] [ bounds-error? ] must-fail-with

{ B{ } } [ "B\x00\x00\x00\x00." pickle> ] unit-test
{ B{ CHAR: a } } [ "B\x01\x00\x00\x00a." pickle> ] unit-test
{ B{ 0xa1 0xa2 0xa3 } } [ "B\x03\x00\x00\x00\xa1\xa2\xa3." pickle> ] unit-test
{ B{ CHAR: a CHAR: b CHAR: c } } [ "B\x03\x00\x00\x00abc." pickle> ] unit-test

{ B{ } } [ "C\x00." pickle> ] unit-test
{ B{ CHAR: a } } [ "C\x01a." pickle> ] unit-test
{ B{ 0xa1 0xa2 0xa3 } } [ "C\x03\xa1\xa2\xa3." pickle> ] unit-test
{ B{ CHAR: a CHAR: b CHAR: c } } [ "C\x03abc." pickle> ] unit-test
{ B{ 97 98 99 100 101 102 } } [ "C\x06abcdef." pickle> ] unit-test

{ 2 } [ "I1\n(I2\n(I3\nI4\n1." pickle> ] unit-test

{ V{ 42 42 } } [ "(I42\n2t." pickle> ] unit-test

{ 0.0 } [ "F0\n." pickle> ] unit-test
{ 0.0 } [ "F0.0\n." pickle> ] unit-test
{ 123.456 } [ "F123.456\n." pickle> ] unit-test
{ 1234.5678 } [ "F1234.5678\n." pickle> ] unit-test
{ -1234.5678 } [ "F-1234.5678\n." pickle> ] unit-test
{ 2.345e+202 } [ "F2.345e+202\n." pickle> ] unit-test
{ -2.345e-202 } [ "F-2.345e-202\n." pickle> ] unit-test
! XXX: [ "F1,2\n." pickle> ] must-fail

{ 1234.5678 } [ "G@\x93JEm\\\xfa\xad." pickle> ] unit-test

{ t } [ "I01\n." pickle> ] unit-test
{ f } [ "I00\n." pickle> ] unit-test
{ 0 } [ "I0\n." pickle> ] unit-test
{ 0 } [ "I-0\n." pickle> ] unit-test
{ 1 } [ "I1\n." pickle> ] unit-test
{ -1 } [ "I-1\n." pickle> ] unit-test
{ 123 } [ "I123\n." pickle> ] unit-test
{ 999999999 } [ "I999999999\n." pickle> ] unit-test
{ -999999999 } [ "I-999999999\n." pickle> ] unit-test
{ 9999999999 } [ "I9999999999\n." pickle> ] unit-test
{ -9999999999 } [ "I-9999999999\n." pickle> ] unit-test
{ 19999999999 } [ "I19999999999\n." pickle> ] unit-test
{ -19999999999 } [ "I-19999999999\n." pickle> ] unit-test
{ 1234567890 } [ "I1234567890\n." pickle> ] unit-test
{ -1234567890 } [ "I-1234567890\n." pickle> ] unit-test
{ 1234567890123456 } [ "I1234567890123456\n." pickle> ] unit-test
! XXX: [ "I1?0\n." pickle> ] must-fail

{ 0 } [ "J\x00\x00\x00\x00." pickle> ] unit-test
{ 1 } [ "J\x01\x00\x00\x00." pickle> ] unit-test
{ -1 } [ "J\xff\xff\xff\xff." pickle> ] unit-test
{ 0x02000001 } [ "J\x01\x00\x00\x02." pickle> ] unit-test
{ 0x45443043 } [ "JC0DE." pickle> ] unit-test
{ -0xf00000f } [ "J\xf1\xff\xff\xf0." pickle> ] unit-test

{ 0 } [ "K\x00." pickle> ] unit-test
{ 128 } [ "K\x80." pickle> ] unit-test
{ 255 } [ "K\xff." pickle> ] unit-test
{ { 1 2 2 } } [ "K\x01\x94K\x02\x94h\x00h\x01h\x01\x87." pickle> ] unit-test

{ 0 } [ "L0\n." pickle> ] unit-test
{ 0 } [ "L-0\n." pickle> ] unit-test
{ 1 } [ "L1\n." pickle> ] unit-test
{ -1 } [ "L-1\n." pickle> ] unit-test
{ 1234 } [ "L1234\n." pickle> ] unit-test
{ 1234567890 } [ "L1234567890\n." pickle> ] unit-test
{ 1234567890123456 } [ "L1234567890123456\n." pickle> ] unit-test
{ -1234567890123456 } [ "L-1234567890123456\n." pickle> ] unit-test
{ 12345678987654321 } [ "L12345678987654321L\n." pickle> ] unit-test
{ 9999888877776666555544443333222211110000 } [ "L9999888877776666555544443333222211110000L\n." pickle> ] unit-test

{ 0 } [ "M\x00\x00." pickle> ] unit-test
{ 255 } [ "M\xff\x00." pickle> ] unit-test
{ 12345 } [ "M90." pickle> ] unit-test
{ 32768 } [ "M\x00\x80." pickle> ] unit-test
{ 65535 } [ "M\xff\xff." pickle> ] unit-test

{ "" } [ "S''\n." pickle> ] unit-test
{ "" } [ "S\"\"\n." pickle> ] unit-test
{ "a" } [ "S'a'\n." pickle> ] unit-test
{ "a" } [ "S\"a\"\n." pickle> ] unit-test
{ "'" } [ "S'\\''\n." pickle> ] unit-test
{ "Foobar" } [ "S'Foobar'\n." pickle> ] unit-test
{ "\xa1\xa2\xa3" } [ "S'\\xa1\\xa2\\xa3'\n." pickle> ] unit-test
{ "a\\x00y" } [ "S'a\\\\x00y'\n." pickle> ] unit-test
[ "S'bla\n." pickle> ] [ invalid-string? ] must-fail-with

{ "" } [ "T\x00\x00\x00\x00." pickle> ] unit-test
{ "a" } [ "T\x01\x00\x00\x00a." pickle> ] unit-test
{ "abc" } [ "T\x03\x00\x00\x00abc." pickle> ] unit-test
{ "\xa1\xa2\xa3" } [ "T\x03\x00\x00\x00\xa1\xa2\xa3." pickle> ] unit-test

{ "" } [ "U\x00." pickle> ] unit-test
{ "a" } [ "U\x01a." pickle> ] unit-test
{ "\xa1\xa2\xa3" } [ "U\x03\xa1\xa2\xa3." pickle> ] unit-test
{ "abc" } [ "U\x03abc." pickle> ] unit-test

{ "" } [ "V\n." pickle> ] unit-test
{ "abc" } [ "Vabc\n." pickle> ] unit-test
{ "\u{20ac}" } [ "V\\u20ac\n." pickle> ] unit-test
{ "a\\u00y" } [ "Va\\u005cu00y\n." pickle> ] unit-test
{ "unicode" } [ "Vunicode\n." pickle> ] unit-test
{ "\x80\xa1\xa2" } [ "V\x80\xa1\xa2\n." pickle> ] unit-test

{ "" } [ "X\x00\x00\x00\x00." pickle> ] unit-test
{ "abc" } [ "X\x03\x00\x00\x00abc." pickle> ] unit-test
{ "€" } [ "X\x03\x00\x00\x00\xe2\x82\xac." pickle> ] unit-test
{ "unicode" } [ "X\x07\x00\x00\x00unicode." pickle> ] unit-test

{ "" } [ "\x8d\x00\x00\x00\x00\x00\x00\x00\x00." pickle> ] unit-test
{ "abc" } [ "\x8d\x03\x00\x00\x00\x00\x00\x00\x00abc." pickle> ] unit-test
{ "€" } [ "\x8d\x03\x00\x00\x00\x00\x00\x00\x00\xe2\x82\xac." pickle> ] unit-test

{ "" } [ "\x8c\x00." pickle> ] unit-test
{ "abc" } [ "\x8c\x03abc." pickle> ] unit-test
{ "€" } [ "\x8c\x03\xe2\x82\xac." pickle> ] unit-test

{ 0 } [ "\x8a\x00." pickle> ] unit-test
{ 0 } [ "\x8a\x01\x00." pickle> ] unit-test
{ 1 } [ "\x8a\x01\x01." pickle> ] unit-test
{ -1 } [ "\x8a\x01\xff." pickle> ] unit-test
{ 0 } [ "\x8a\x02\x00\x00." pickle> ] unit-test
{ 1 } [ "\x8a\x02\x01\x00." pickle> ] unit-test
{ 513 } [ "\x8a\x02\x01\x02." pickle> ] unit-test
{ -256 } [ "\x8a\x02\x00\xff." pickle> ] unit-test
{ 65280 } [ "\x8a\x03\x00\xff\x00." pickle> ] unit-test
{ 0x12345678 } [ "\x8a\x04\x78\x56\x34\x12." pickle> ] unit-test
{ -231451016 } [ "\x8a\x04\x78\x56\x34\xf2." pickle> ] unit-test
{ 0xf2345678 } [ "\x8a\x05\x78\x56\x34\xf2\x00." pickle> ] unit-test
{ 12345678987654321 } [ "\x8a\x07\xb1\xf4\x91\x62\x54\xdc\x2b." pickle> ] unit-test
{ 123456789123456789 } [ "\x8a\x08\x15_\xd0\xacK\x9b\xb6\x01." pickle> ] unit-test
{ 123456789123456789123456789123456789 } [ "\x8a\x0f\x15_\x04\x84ft\xadE\x90\xf82\xc0\xe3\xc6\x17." pickle> ] unit-test

{ 0 } [ "\x8b\x00\x00\x00\x00." pickle> ] unit-test
{ 0 } [ "\x8b\x01\x00\x00\x00\x00." pickle> ] unit-test
{ 1 } [ "\x8b\x01\x00\x00\x00\x01." pickle> ] unit-test
{ -1 } [ "\x8b\x01\x00\x00\x00\xff." pickle> ] unit-test
{ 0 } [ "\x8b\x02\x00\x00\x00\x00\x00." pickle> ] unit-test
{ 1 } [ "\x8b\x02\x00\x00\x00\x01\x00." pickle> ] unit-test
{ 513 } [ "\x8b\x02\x00\x00\x00\x01\x02." pickle> ] unit-test
{ -256 } [ "\x8b\x02\x00\x00\x00\x00\xff." pickle> ] unit-test
{ 65280 } [ "\x8b\x03\x00\x00\x00\x00\xff\x00." pickle> ] unit-test
{ 0x12345678 } [ "\x8b\x04\x00\x00\x00\x78\x56\x34\x12." pickle> ] unit-test
{ -231451016 } [ "\x8b\x04\x00\x00\x00\x78\x56\x34\xf2." pickle> ] unit-test
{ 0xf2345678 } [ "\x8b\x05\x00\x00\x00\x78\x56\x34\xf2\x00." pickle> ] unit-test
{ 12345678987654321 } [ "\x8b\x07\x00\x00\x00\xb1\xf4\x91\x62\x54\xdc\x2b." pickle> ] unit-test
{ 12345678987654321 } [ "\x8b\x07\x00\x00\x00\xb1\xf4\x91\x62\x54\xdc\x2b." pickle> ] unit-test

{ t } [ "\x88." pickle> ] unit-test

{ f } [ "\x89." pickle> ] unit-test

{ B{ 97 98 99 } } [ "c__builtin__\nbytes\np0\n((lp1\nL97L\naL98L\naL99L\natp2\nRp3\n." pickle> ] unit-test
{ B{ 97 98 99 } } [ "c__builtin__\nbytes\n(](KaKbKcetR." pickle> ] unit-test
{ DECIMAL: 123.456 } [ "cdecimal\nDecimal\n(V123.456\ntR." pickle> ] unit-test
{ DECIMAL: 123.456 } [ "cdecimal\nDecimal\n(V123.456\nt}\x92." pickle> ] unit-test
[ "cdecimal\nDecimal\n(V123.456\nt}\x8c\x04testK1s\x92." pickle> ] must-fail

{ V{ } } [ "]." pickle> ] unit-test
{ V{ 42 43 } } [ "]I42\naI43\na." pickle> ] unit-test

{ { } } [ ")." pickle> ] unit-test

{ H{ } } [ "}." pickle> ] unit-test
{ H{ } } [ "}N0." pickle> ] unit-test
{ H{ { "a" 42 } { "b" 99 } } } [ "(S'a'\nI42\nS'b'\nI99\nd." pickle> ] unit-test
{ H{ { "a" 42 } { "b" 43 } } } [ "}S'a'\nI42\nsS'b'\nI43\ns." pickle> ] unit-test
{ H{ { "b" 43 } { "c" 44 } } } [ "}(S'b'\nI43\nS'c'\nI44\nu." pickle> ] unit-test
{ H{ { "a" 42 } { "b" 43 } { "c" 44 } } } [ "}S'a'\nI42\ns(S'b'\nI43\nS'c'\nI44\nu." pickle> ] unit-test

{ V{ "abc" "abc" "abc" } } [ "(lp0\nS'abc'\np1\nag1\nag1\na." pickle> ] unit-test

{ V{ "abc" "abc" "abc" } } [ "]q\x00(U\x03abcq\x01h\x01h\x01e." pickle> ] unit-test
[ "]q\x00(U\x03abcq\x01h\x02h\x02e." pickle> ] [ invalid-memo? ] must-fail-with

{ V{ "abc" "abc" "abc" } } [ "]r\x00\x00\x00\x00(U\x03abcr\x01\x02\x03\x04j\x01\x02\x03\x04j\x01\x02\x03\x04e." pickle> ] unit-test
[ "]r\x00\x00\x00\x00(U\x03abcr\x01\x02\x03\x04j\x01\x05\x05\x05j\x01\x05\x05\x05e." pickle> ] [ invalid-memo? ] must-fail-with

{ V{ 1 2 } } [ "(I1\nI2\nl." pickle> ] unit-test
{ V{ 1 2 } } [ "(I1\nI2\nt." pickle> ] unit-test

{ B{ } } [ "\x8e\x00\x00\x00\x00\x00\x00\x00\x00." pickle> ] unit-test
{ B{ CHAR: a } } [ "\x8e\x01\x00\x00\x00\x00\x00\x00\x00a." pickle> ] unit-test
{ B{ 0xa1 0xa2 0xa3 } } [ "\x8e\x03\x00\x00\x00\x00\x00\x00\x00\xa1\xa2\xa3." pickle> ] unit-test

{ HS{ } } [ "\x8f." pickle> ] unit-test
{ HS{ } } [ "\x8f(\x90." pickle> ] unit-test
{ HS{ 42 "a" } } [ "\x8f(K\x2a\x8c\x01a\x90." pickle> ] unit-test

{ "tshirt👕" } [ "Vtshirt\u{0001f455}\np0\n." pickle> ] unit-test
{ "tshirt👕" } [ "\x80\x02X\n\x00\x00\x00tshirt\xf0\x9f\x91\x95." pickle> ] unit-test

{ null } [ "\x80\x00N." pickle> ] unit-test
{ null } [ "\x80\x01N." pickle> ] unit-test
{ null } [ "\x80\x02N." pickle> ] unit-test
{ null } [ "\x80\x03N." pickle> ] unit-test
{ null } [ "\x80\x04N." pickle> ] unit-test
[ "\x80\x09N." pickle> ] [ unsupported-protocol? ] must-fail-with

[ "\x82\x01." pickle> ] [ unsupported-feature? ] must-fail-with
[ "\x83\x01\x02." pickle> ] [ unsupported-feature? ] must-fail-with
[ "\x84\x01\x02\x03\x04." pickle> ] [ unsupported-feature? ] must-fail-with

{ { 42 } } [ "I41\nI42\n\x85." pickle> ] unit-test
{ { 42 43 } } [ "I41\nI42\nI43\n\x86." pickle> ] unit-test
{ { 42 43 44 } } [ "I41\nI42\nI43\nI44\n\x87." pickle> ] unit-test

{ B{ CHAR: a CHAR: b CHAR: c } } [ "\x80\x05\x95\x0e\x00\x00\x00\x00\x00\x00\x90\x96\x03\x00\x00\x00\x00\x00\x00\x00abc\x94." pickle> ] unit-test
