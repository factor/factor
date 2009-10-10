! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax kernel destructors
core-foundation core-foundation.dictionaries
core-foundation.strings
core-foundation.utilities ;
IN: core-foundation.attributed-strings

TYPEDEF: void* CFAttributedStringRef

FUNCTION: CFAttributedStringRef CFAttributedStringCreate (
   CFAllocatorRef alloc,
   CFStringRef str,
   CFDictionaryRef attributes
) ;

: <CFAttributedString> ( string assoc -- alien )
    [
        [ >cf &CFRelease ] bi@
        [ kCFAllocatorDefault ] 2dip CFAttributedStringCreate
    ] with-destructors ;
