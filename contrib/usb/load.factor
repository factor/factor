! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;

PROVIDE: contrib/usb { 
	"usb-common.factor" 
	{ "usb-unix.factor" [ unix? ] }
	{ "usb-win32.factor" [ win32? ] }
	"usb.factor" 
} { 
} ;
