! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax core-foundation kernel assocs alien.c-types
specialized-arrays.alien math sequences accessors ;
IN: core-foundation.dictionaries

TYPEDEF: void* CFDictionaryRef
TYPEDEF: void* CFMutableDictionaryRef
TYPEDEF: void* CFDictionaryKeyCallBacks*
TYPEDEF: void* CFDictionaryValueCallBacks*

FUNCTION: CFDictionaryRef CFDictionaryCreate (
   CFAllocatorRef allocator,
   void** keys,
   void** values,
   CFIndex numValues,
   CFDictionaryKeyCallBacks* keyCallBacks,
   CFDictionaryValueCallBacks* valueCallBacks
) ;

: <CFDictionary> ( alist -- dictionary )
    [ kCFAllocatorDefault ] dip
    unzip [ >void*-array ] bi@
    dup length "void*" heap-size /i
    [ [ underlying>> ] bi@ ] dip
    &: kCFTypeDictionaryCallBacks
    &: kCFTypeDictionaryValueCallbacks
    CFDictionaryCreate ;