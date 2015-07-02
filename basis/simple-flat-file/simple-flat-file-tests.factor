! Copyright (C) 2009 Yun, Jonghyouk.
! See http://factorcode.org/license.txt for BSD license.
USING: simple-flat-file tools.test memoize assocs ;
IN: simple-flat-file.tests


MEMO: <test1> ( -- code-table )
    "vocab:simple-flat-file/test1.txt" flat-file>biassoc ;


[ 0 ] [ 0 <test1> at ] unit-test
[ 0 ] [ 0 <test1> value-at ] unit-test

[ 3 ] [ 3 <test1> at ] unit-test
[ 3 ] [ 3 <test1> value-at ] unit-test

[ 0xAD2A ] [ 0x8253 <test1> at ] unit-test
[ 0x8253 ] [ 0xAD2A <test1> value-at ] unit-test

[ 0xAD31 ] [ 0x8258 <test1> at ] unit-test
[ 0x8258 ] [ 0xAD31 <test1> value-at ] unit-test
