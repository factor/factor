! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: alien kernel ;

"ogg" {
    { [ win32? ]  [ "ogg.dll" ] }
    { [ macosx? ] [ "libogg.0.dylib" ] }
    { [ unix? ]   [ "libogg.so" ] }
} cond "cdecl" add-library

PROVIDE: libs/ogg
{ +files+ {
	"libogg.factor" 
} } ;
