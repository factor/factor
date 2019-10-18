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

[ HEX: AD2A ] [ HEX: 8253 <test1> at ] unit-test
[ HEX: 8253 ] [ HEX: AD2A <test1> value-at ] unit-test

[ HEX: AD31 ] [ HEX: 8258 <test1> at ] unit-test
[ HEX: 8258 ] [ HEX: AD31 <test1> value-at ] unit-test


