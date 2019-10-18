! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax core-foundation core-foundation.strings
javascriptcore.ffi ;
IN: javascriptcore.core-foundation

FUNCTION: JSStringRef JSStringCreateWithCFString ( CFStringRef string ) ;

FUNCTION: CFStringRef JSStringCopyCFString ( CFAllocatorRef alloc, JSStringRef string ) ;


