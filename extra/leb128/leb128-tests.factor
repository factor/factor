
USING: leb128 tools.test ;

{ B{ 0xe5 0x8e 0x26 } } [ 624485 >leb128 ] unit-test
{ 624485 } [ B{ 0xe5 0x8e 0x26 } leb128> ] unit-test

{ B{ 0xc0 0xbb 0x78 } } [ -123456 >leb128 ] unit-test
{ -123456 } [ B{ 0xc0 0xbb 0x78 } leb128> ] unit-test
