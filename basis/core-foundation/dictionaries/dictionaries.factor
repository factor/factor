! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax core-foundation kernel assocs
specialized-arrays math sequences accessors ;
IN: core-foundation.dictionaries

SPECIALIZED-ARRAY: void*

TYPEDEF: void* CFDictionaryRef
TYPEDEF: void* CFMutableDictionaryRef
C-TYPE: CFDictionaryKeyCallBacks
C-TYPE: CFDictionaryValueCallBacks

FUNCTION: CFDictionaryRef CFDictionaryCreate (
   CFAllocatorRef allocator,
   void** keys,
   void** values,
   CFIndex numValues,
   CFDictionaryKeyCallBacks* keyCallBacks,
   CFDictionaryValueCallBacks* valueCallBacks
) ;

FUNCTION: void* CFDictionaryGetValue (
   CFDictionaryRef theDict,
   void* key
) ;

: <CFDictionary> ( alist -- dictionary )
    [ kCFAllocatorDefault ] dip
    unzip [ >void*-array ] bi@
    [ [ underlying>> ] bi@ ] [ nip length ] 2bi
    &: kCFTypeDictionaryKeyCallBacks
    &: kCFTypeDictionaryValueCallBacks
    CFDictionaryCreate ;
