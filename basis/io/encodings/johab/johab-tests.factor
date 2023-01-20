! Copyright (C) 2009 Yun, Jonghyouk.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays io io.encodings io.encodings.johab assocs
io.encodings.string io.streams.string io.encodings.euc.private words
kernel locals multiline namespaces sequences strings tools.test ;
IN: io.encodings.johab.tests

: johab>unicode ( ch -- ch/f )
    johab euc-table word-prop at ;

: unicode>johab ( ch -- ch/f )
    johab euc-table word-prop value-at ;

! johab encodings
{ 0x20 } [ 0x20 johab>unicode ] unit-test
{ 0x3133 } [ 0x8444 johab>unicode ] unit-test
{ 0x8A5D } [ 0xAD4F unicode>johab ] unit-test

: phrase-unicode ( -- s )
    "\u00b3d9\u00d574\u00bb3c\u00acfc \u00bc31\u00b450\u00c0b0\u00c774!" ;

: phrase-johab ( -- s )
    B{
        149 183 208 129 162 137 137 193 32 164 130 150 129 172 101
        183 161 33
    } ;

: phrase-johab>unicode ( -- s )
    phrase-johab johab decode ;

: phrase-unicode>johab ( -- s )
    phrase-unicode johab encode ;

{ t } [ phrase-johab>unicode phrase-unicode = ] unit-test
{ t } [ phrase-unicode>johab phrase-johab = ] unit-test
