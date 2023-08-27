! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: classes.struct tools.test windows.types ;
IN: windows.types.tests

[ S{ RECT { right 100 } { bottom 100 } } ]
[ { 0 0 } { 100 100 } <RECT> ] unit-test

[ S{ RECT { left 100 } { top 100 } { right 200 } { bottom 200 } } ]
[ { 100 100 } { 100 100 } <RECT> ] unit-test
