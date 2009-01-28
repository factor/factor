! Copyright (C) 2008 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test tools.files strings kernel ;
IN: tools.files.tests

\ directory. must-infer

[ ] [ "" directory. ] unit-test

[ ] [ file-systems. ] unit-test
