! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
REQUIRES: libs/shuffle libs/alien ;
USING: alien kernel ;

"alut" {
{ [ win32? ]  [ "alut.dll" ] }
{ [ macosx? ] [ "/System/Library/Frameworks/OpenAL.framework/OpenAL" ] }
{ [ unix?  ]  [ "libalut.so" ] }
} cond "cdecl" add-library

"openal" {
{ [ win32? ]  [ "OpenAL32.dll" ] }
{ [ macosx? ] [ "/System/Library/Frameworks/OpenAL.framework/OpenAL" ] }
{ [ unix?  ]  [ "libopenal.so" ] }
} cond "cdecl" add-library

PROVIDE: libs/openal
{ +files+ {
	"openal.factor" 
	"alut.factor"
        { "alut-mac.factor" [ macosx? ] } 
        { "alut-other.factor" [ macosx? not ] } 
	"api.factor" 
	"example.factor" 
} } ;
