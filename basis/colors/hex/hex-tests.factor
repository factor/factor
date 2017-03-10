! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: colors colors.hex tools.test ;

{ HEXCOLOR: 000000 } [ 0.0 0.0 0.0 1.0 <rgba> ] unit-test
{ HEXCOLOR: FFFFFF } [ 1.0 1.0 1.0 1.0 <rgba> ] unit-test
{ HEXCOLOR: abcdef } [ "abcdef" hex>rgba ] unit-test
{ HEXCOLOR: abcdef } [ "ABCDEF" hex>rgba ] unit-test
{ "ABCDEF" } [ HEXCOLOR: abcdef rgba>hex ] unit-test

{ HEXCOLOR: 00000000 } [ 0.0 0.0 0.0 0.0 <rgba> ] unit-test
{ HEXCOLOR: FF000000 } [ 1.0 0.0 0.0 0.0 <rgba> ] unit-test
{ HEXCOLOR: FFFF0000 } [ 1.0 1.0 0.0 0.0 <rgba> ] unit-test
{ HEXCOLOR: FFFFFF00 } [ 1.0 1.0 1.0 0.0 <rgba> ] unit-test
{ HEXCOLOR: FFFFFFFF } [ 1.0 1.0 1.0 1.0 <rgba> ] unit-test

{ HEXCOLOR: cafebabe } [ "cafebabe" hex>rgba ] unit-test
{ HEXCOLOR: 112233 } [ "123" hex>rgba ] unit-test
{ HEXCOLOR: 11223344 } [ "1234" hex>rgba ] unit-test
