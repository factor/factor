! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: colors colors.hex tools.test ;

IN: colors.hex.test

{ HEXCOLOR: 000000 } [ 0.0 0.0 0.0 1.0 <rgba> ] unit-test
{ HEXCOLOR: FFFFFF } [ 1.0 1.0 1.0 1.0 <rgba> ] unit-test
{ HEXCOLOR: abcdef } [ "abcdef" hex>rgba ] unit-test
{ HEXCOLOR: abcdef } [ "ABCDEF" hex>rgba ] unit-test
{ "ABCDEF" } [ HEXCOLOR: abcdef rgba>hex ] unit-test
