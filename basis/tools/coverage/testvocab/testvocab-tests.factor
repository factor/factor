! Copyright (C) 2014 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test tools.coverage.testvocab tools.coverage.testvocab.private ;
IN: tools.coverage.testvocab.tests

{ } [ t testifprivate ] unit-test
{ } [ f testifprivate ] unit-test
{ } [ t testif ] unit-test
{ } [ f testif ] unit-test
{ } [ f halftested ] unit-test
{ 0 } [ 0 testcond ] unit-test
{ 1 } [ 1 testcond ] unit-test
{ 2 } [ 2 testcond ] unit-test
{ 1 2 3 } [ { [ 1 ] [ 2 3 ] } mconcat ] unit-test
{ } [ 1 2 testmacro ] unit-test
{ } [ 2 1 testmacro ] unit-test
{ } [ t testfry ] unit-test
{ } [ f testfry ] unit-test
