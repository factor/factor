! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel core-foundation
core-foundation.strings core-foundation.dictionaries ;
IN: core-foundation.attributed-strings

TYPEDEF: void* CFAttributedStringRef

FUNCTION: CFAttributedStringRef CFAttributedStringCreate (
   CFAllocatorRef alloc,
   CFStringRef str,
   CFDictionaryRef attributes
) ;

: <CFAttributedString> ( string alist -- alien )
    [ <CFString> ] [ <CFDictionary> ] bi*
    [ [ kCFAllocatorDefault ] 2dip CFAttributedStringCreate ]
    [ [ CFRelease ] bi@ ]
    2bi ;