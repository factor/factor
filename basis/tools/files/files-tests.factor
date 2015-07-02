! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test tools.files strings kernel ;
IN: tools.files.tests

{ } [ "" directory. ] unit-test

{ } [ file-systems. ] unit-test
