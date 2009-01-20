! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test core-graphics kernel byte-arrays ;
IN: core-graphics.tests

[ t ] [ { 100 200 } [ drop ] with-bitmap-context byte-array? ] unit-test