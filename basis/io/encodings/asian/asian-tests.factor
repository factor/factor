! Copyright (C) 2009 Yun, Jonghyouk.
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings.asian tools.test memoize ;
IN: io.encodings.asian.tests


MEMO: <test1> ( -- code-table )
    "vocab:io/encodings/asian/data/test1.txt" <code-table>* ;


[ 0 ] [ 0 <test1> n>u ] unit-test
[ 0 ] [ 0 <test1> u>n ] unit-test

[ 3 ] [ 3 <test1> n>u ] unit-test
[ 3 ] [ 3 <test1> u>n ] unit-test

[ HEX: AD2A ] [ HEX: 8253 <test1> n>u ] unit-test
[ HEX: 8253 ] [ HEX: AD2A <test1> u>n ] unit-test

[ HEX: AD31 ] [ HEX: 8258 <test1> n>u ] unit-test
[ HEX: 8258 ] [ HEX: AD31 <test1> u>n ] unit-test


