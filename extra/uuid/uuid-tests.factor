! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel uuid uuid.private tools.test ;

IN: uuid.tests

[ t ] [ NAMESPACE_URL [ string>uuid uuid>string ] keep = ] unit-test
[ t ] [ NAMESPACE_URL string>uuid [ uuid>byte-array byte-array>uuid ] keep = ] unit-test


