! Copyright (C) 2007 Adam Wendt.
! See http://factorcode.org/license.txt for BSD license.
REQUIRES: libs/shuffle libs/alien libs/vars ;
USING: kernel ;

PROVIDE: libs/mad
{ +files+ {
	"mad.factor" 
    "api.factor"
} }
 { +tests+ {
    "tests.factor"
 } }
;

