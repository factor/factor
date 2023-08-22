! Copyright (C) 2009 Yun, Jonghyouk.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays io io.encodings io.encodings.euc-kr assocs
io.encodings.string io.streams.string io.encodings.euc.private words
kernel locals multiline namespaces sequences strings tools.test ;
IN: io.encodings.euc.tests

: euc-kr>unicode ( ch -- ch/f )
    euc-kr euc-table word-prop at ;

: unicode>euc-kr ( ch -- ch/f )
    euc-kr euc-table word-prop value-at ;

{ f } [ 0x80 euc-kr>unicode ] unit-test
{ f } [ 0xff euc-kr>unicode ] unit-test
{ 0xac02 } [ 0x8141 euc-kr>unicode ] unit-test
{ 0x7f } [ 0x7f euc-kr>unicode ] unit-test
{ 0xc724 } [ 0xc0b1 euc-kr>unicode ] unit-test

{ 0x8141 } [ 0xac02 unicode>euc-kr ] unit-test
{ 0x7f } [ 0x7f unicode>euc-kr ] unit-test
{ 0xc0b1 } [ 0xc724 unicode>euc-kr ] unit-test

: phrase-unicode ( -- s )
    "\u00b3d9\u00d574\u00bb3c\u00acfc \u00bc31\u00b450\u00c0b0\u00c774!" ;

: phrase-euc-kr ( -- s )
    {
        0xb5 0xbf 0xc7 0xd8
        0xb9 0xb0 0xb0 0xfa
        0x20 0xb9 0xe9 0xb5
        0xce 0xbb 0xea 0xc0
        0xcc 0x21
    } ;

: phrase-unicode>euc-kr ( -- s )
    phrase-unicode euc-kr encode ;

: phrase-euc-kr>unicode ( -- s )
    phrase-euc-kr euc-kr decode ;

{ t } [ phrase-unicode>euc-kr >array phrase-euc-kr = ] unit-test

{ t }  [ phrase-euc-kr>unicode phrase-unicode = ] unit-test

{ t } [ phrase-euc-kr 1 head* euc-kr decode phrase-unicode 1 head* = ] unit-test

{ t } [ phrase-euc-kr 3 head* euc-kr decode phrase-unicode 2 head* = ] unit-test

{ t } [ phrase-euc-kr 2 head* euc-kr decode phrase-unicode 2 head* CHAR: replacement-character suffix = ] unit-test
