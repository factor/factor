! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: alien kernel ;
REQUIRES: libs/ogg libs/vorbis ;

"theora" {
    { [ win32? ]  [ "libtheora.dll" ] }
    { [ macosx? ] [ "libtheora.0.dylib" ] }
    { [ unix? ]   [ "libtheora.so" ] }
} cond "cdecl" add-library

PROVIDE: libs/theora
{ +files+ {
	"libtheora.factor" 
} } ;
