! Copyright (C) 2009 Yun, Jonghyouk.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays io io.encodings io.encodings.euc-kr assocs
io.encodings.string io.streams.string io.encodings.euc.private words
kernel locals multiline namespaces sequences strings tools.test ;
IN: io.encodings.euc.tests

: euc-kr>unicode ( ch -- ch/f )
    euc-kr euc-table word-prop at ;

: unicode>euc-kr ( ch -- ch/f )
    euc-kr euc-table word-prop value-at ;

[ f ] [ HEX: 80 euc-kr>unicode ] unit-test
[ f ] [ HEX: ff euc-kr>unicode ] unit-test
[ HEX: ac02 ] [ HEX: 8141 euc-kr>unicode ] unit-test
[ HEX: 7f ] [ HEX: 7f euc-kr>unicode ] unit-test
[ HEX: c724 ] [ HEX: c0b1 euc-kr>unicode ] unit-test

[ HEX: 8141 ] [ HEX: ac02 unicode>euc-kr ] unit-test
[ HEX: 7f ] [ HEX: 7f unicode>euc-kr ] unit-test
[ HEX: c0b1 ] [ HEX: c724 unicode>euc-kr ] unit-test

: phrase-unicode ( -- s )
    "\u00b3d9\u00d574\u00bb3c\u00acfc \u00bc31\u00b450\u00c0b0\u00c774!" ;

: phrase-euc-kr ( -- s )
    {
        HEX: b5 HEX: bf HEX: c7 HEX: d8
        HEX: b9 HEX: b0 HEX: b0 HEX: fa
        HEX: 20 HEX: b9 HEX: e9 HEX: b5
        HEX: ce HEX: bb HEX: ea HEX: c0
        HEX: cc HEX: 21
    } ;

: phrase-unicode>euc-kr ( -- s )
    phrase-unicode euc-kr encode ;

: phrase-euc-kr>unicode ( -- s )
    phrase-euc-kr euc-kr decode ;

[ t ] [ phrase-unicode>euc-kr >array phrase-euc-kr = ] unit-test

[ t ]  [ phrase-euc-kr>unicode phrase-unicode = ] unit-test

[ t ] [ phrase-euc-kr 1 head* euc-kr decode phrase-unicode 1 head* = ] unit-test

[ t ] [ phrase-euc-kr 3 head* euc-kr decode phrase-unicode 2 head* = ] unit-test

[ t ] [ phrase-euc-kr 2 head* euc-kr decode phrase-unicode 2 head* CHAR: replacement-character suffix = ] unit-test
