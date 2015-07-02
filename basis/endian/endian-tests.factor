! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces tools.test endian ;
IN: endian.tests

[ t ] [ [ endianness get big-endian = ] with-big-endian ] unit-test
[ t ] [ [ endianness get little-endian = ] with-little-endian ] unit-test
