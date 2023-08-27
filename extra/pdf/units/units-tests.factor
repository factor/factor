! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: pdf.units tools.test ;

{ 0 } [ "0" string>points ] unit-test
{ 1 } [ "1" string>points ] unit-test
{ 1.5 } [ "1.5" string>points ] unit-test

{ 12 } [ "12pt" string>points ] unit-test

{ 72.0 } [ "1in" string>points ] unit-test
{ 108.0 } [ "1.5in" string>points ] unit-test
