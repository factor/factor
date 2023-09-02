
USING: leb128 math tools.test ;

[ -1 >uleb128 ] [ non-negative-number-expected? ] must-fail-with
{ B{ 0xe5 0x8e 0x26 } } [ 624485 >uleb128 ] unit-test
{ 624485 } [ B{ 0xe5 0x8e 0x26 } uleb128> ] unit-test
{ B{ 255 255 127 } } [ 0x1fffff >uleb128 ] unit-test
{ 0x1fffff } [ B{ 255 255 127 } uleb128> ] unit-test

{ B{ 255 255 255 0 } } [ 0x1fffff >leb128 ] unit-test
{ 0x1fffff } [ B{ 255 255 255 0 } leb128> ] unit-test
{ B{ 0xc0 0xbb 0x78 } } [ -123456 >leb128 ] unit-test
{ -123456 } [ B{ 0xc0 0xbb 0x78 } leb128> ] unit-test
