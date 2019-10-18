! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: endian kernel namespaces tools.test ;

{ t } [ [ endianness get big-endian = ] with-big-endian ] unit-test
{ t } [ [ endianness get little-endian = ] with-little-endian ] unit-test
