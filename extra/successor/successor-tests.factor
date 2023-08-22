! Copyright (C) 2011 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: successor tools.test ;

{ "" } [ "" successor ] unit-test
{ "abce" } [ "abcd" successor ] unit-test
{ "THX1139" } [ "THX1138" successor ] unit-test
{ "<<koalb>>" } [ "<<koala>>" successor ] unit-test
{ "2000aaa" } [ "1999zzz" successor ] unit-test
{ "AAAA0000" } [ "ZZZ9999" successor ] unit-test
{ "**+" } [ "***" successor ] unit-test
