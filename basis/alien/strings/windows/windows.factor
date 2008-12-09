! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.strings alien.c-types io.encodings.utf8
io.encodings.utf16n system ;
IN: alien.strings.windows

M: windows alien>native-string utf16n alien>string ;

M: wince native-string>alien utf16n string>alien ;

M: winnt native-string>alien utf8 string>alien ;

{ "char*" utf16n } "wchar_t*" typedef
