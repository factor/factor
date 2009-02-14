! Copyright (C) 2009 Yun, Jonghyouk.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays io io.encodings io.encodings.korean
io.encodings.korean.private io.encodings.string io.streams.string
kernel locals multiline namespaces sequences strings tools.test ;
IN: io.encodings.korean.tests



! convert cp949 <-> unicode

[ f ] [ HEX: 80 (cp949->unicode) ] unit-test
[ f ] [ HEX: ff (cp949->unicode) ] unit-test
[ HEX: ac02 ] [ HEX: 8141 (cp949->unicode) ] unit-test
[ HEX: 7f ] [ HEX: 7f (cp949->unicode) ] unit-test
[ HEX: c724 ] [ HEX: c0b1 (cp949->unicode) ] unit-test

[ HEX: 8141 ] [ HEX: ac02 (unicode->cp949) ] unit-test
[ HEX: 7f ] [ HEX: 7f (unicode->cp949) ] unit-test
[ HEX: c0b1 ] [ HEX: c724 (unicode->cp949) ] unit-test


! byte manip.
[ HEX: beaf ] [ HEX: be HEX: af (2b->1mb) ] unit-test
[ HEX: be ] [ HEX: beaf (1mb->1st) ] unit-test
[ HEX: af ] [ HEX: beaf (1mb->2nd) ] unit-test
[ HEX: be HEX: af ] [ HEX: beaf (1mb->2b) ] unit-test


!
: (t-phrase-unicode) ( -- s )
    "\u00b3d9\u00d574\u00bb3c\u00acfc \u00bc31\u00b450\u00c0b0\u00c774!" ;

: (t-phrase-cp949) ( -- s )
    {
        HEX: b5 HEX: bf HEX: c7 HEX: d8
        HEX: b9 HEX: b0 HEX: b0 HEX: fa
        HEX: 20 HEX: b9 HEX: e9 HEX: b5
        HEX: ce HEX: bb HEX: ea HEX: c0
        HEX: cc HEX: 21
    } ;

: (t-phrase-unicode->cp949) ( -- s )
    (t-phrase-unicode) cp949 encode ;

: (t-phrase-cp949->unicode) ( -- s )
    (t-phrase-cp949) cp949 decode ;


[ t ] [ (t-phrase-unicode->cp949) >array (t-phrase-cp949) = ] unit-test

[ t ]  [ (t-phrase-cp949->unicode) (t-phrase-unicode) = ] unit-test





! EOF
