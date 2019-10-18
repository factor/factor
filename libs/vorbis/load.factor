! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel alien ;
REQUIRES: libs/openal libs/ogg libs/shuffle ;

"vorbis" {
    { [ win32? ]  [ "vorbis.dll" ] }
    { [ macosx? ] [ "libvorbis.0.dylib" ] }
    { [ unix? ]   [ "libvorbis.so" ] }
} cond "cdecl" add-library

PROVIDE: libs/vorbis
{ +files+ {
	"libvorbis.factor" 
} }  ;

