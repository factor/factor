! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien assocs byte-arrays core-foundation
core-foundation.arrays core-foundation.data
core-foundation.dictionaries core-foundation.numbers
core-foundation.strings destructors hashtables kernel math
sequences strings ;
IN: core-foundation.utilities

GENERIC: (>cf) ( obj -- cf )

M: number (>cf) <CFNumber> ;
M: t (>cf) <CFNumber> ;
M: f (>cf) <CFNumber> ;
M: string (>cf) <CFString> ;
M: byte-array (>cf) <CFData> ;
M: hashtable (>cf) [ [ (>cf) &CFRelease ] bi@ ] assoc-map <CFDictionary> ;
M: sequence (>cf) [ (>cf) &CFRelease ] map <CFArray> ;
M: alien (>cf) CFRetain ;

: >cf ( obj -- cf ) [ (>cf) ] with-destructors ;
