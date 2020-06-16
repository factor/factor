! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sections tools.test ;
IN: sections+tests

{ } [ "math" vocab>section-paths drop ] unit-test
{ } [ "vocab:math" vocab>section-paths drop ] unit-test