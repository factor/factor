! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
REQUIRES: libs/shuffle libs/alien ;
USING: kernel ;

PROVIDE: libs/openal
{ +files+ {
	"openal.factor" 
	"alut.factor"
        { "alut-mac.factor" [ macosx? ] } 
        { "alut-other.factor" [ macosx? not ] } 
	"api.factor" 
	"example.factor" 
} } ;
