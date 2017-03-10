! Copyright (C) 2016 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test checksums.process ;
IN: checksums.process.tests

{ "" } [ "" trim-hash ] unit-test
{ "" } [ " aoeu" trim-hash ] unit-test
{ "aoeu" } [ "aoeu" trim-hash ] unit-test
{ "aoeu" } [ "aoeu i" trim-hash ] unit-test
