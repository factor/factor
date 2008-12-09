! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.strings io.encodings.utf8 system ;
IN: alien.strings.unix

M: unix alien>native-string utf8 alien>string ;

M: unix native-string>alien utf8 string>alien ;
