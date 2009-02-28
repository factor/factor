! Copyright (C) 2009 Yun, Jonghyouk.
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings.blackhole io.encodings.string kernel tools.test ;
IN: io.encodings.blackhole.tests

[ t ] [ "foobar" blackhole encode B{ } = ] unit-test
[ t ] [ "foobar" blackhole decode f = ] unit-test
