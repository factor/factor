! Copyright (C) 2009 Yun, Jonghyouk.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays io io.encodings io.encodings.korean
io.encodings.korean.private io.encodings.string io.streams.string
kernel locals multiline namespaces sequences strings tools.test ;
IN: io.encodings.korean.tests


! cp949 encodings

[ f ] [ HEX: 80 cp949>unicode ] unit-test
[ f ] [ HEX: ff cp949>unicode ] unit-test
[ HEX: ac02 ] [ HEX: 8141 cp949>unicode ] unit-test
[ HEX: 7f ] [ HEX: 7f cp949>unicode ] unit-test
[ HEX: c724 ] [ HEX: c0b1 cp949>unicode ] unit-test

[ HEX: 8141 ] [ HEX: ac02 unicode>cp949 ] unit-test
[ HEX: 7f ] [ HEX: 7f unicode>cp949 ] unit-test
[ HEX: c0b1 ] [ HEX: c724 unicode>cp949 ] unit-test

: phrase-unicode ( -- s )
    "\u00b3d9\u00d574\u00bb3c\u00acfc \u00bc31\u00b450\u00c0b0\u00c774!" ;

: phrase-cp949 ( -- s )
    {
        HEX: b5 HEX: bf HEX: c7 HEX: d8
        HEX: b9 HEX: b0 HEX: b0 HEX: fa
        HEX: 20 HEX: b9 HEX: e9 HEX: b5
        HEX: ce HEX: bb HEX: ea HEX: c0
        HEX: cc HEX: 21
    } ;

: phrase-unicode>cp949 ( -- s )
    phrase-unicode cp949 encode ;

: phrase-cp949>unicode ( -- s )
    phrase-cp949 cp949 decode ;

[ t ] [ phrase-unicode>cp949 >array phrase-cp949 = ] unit-test

[ t ]  [ phrase-cp949>unicode phrase-unicode = ] unit-test

[ t ] [ phrase-cp949 1 head* cp949 decode phrase-unicode 1 head* = ] unit-test

[ t ] [ phrase-cp949 3 head* cp949 decode phrase-unicode 2 head* = ] unit-test

[ t ] [ phrase-cp949 2 head* cp949 decode phrase-unicode 2 head* CHAR: replacement-character suffix = ] unit-test


! johab encodings
[ HEX: 20 ] [ HEX: 20 johab>unicode ] unit-test
[ HEX: 3133 ] [ HEX: 8444 johab>unicode ] unit-test
[ HEX: 8A5D ] [ HEX: AD4F unicode>johab ] unit-test


: phrase-johab ( -- s )
    B{
        149 183 208 129 162 137 137 193 32 164 130 150 129 172 101
        183 161 33
    } ;

: phrase-johab>unicode ( -- s )
    phrase-johab johab decode ;

: phrase-unicode>johab ( -- s )
    phrase-unicode johab encode ;

[ t ] [ phrase-johab>unicode phrase-unicode = ] unit-test
[ t ] [ phrase-unicode>johab phrase-johab = ] unit-test