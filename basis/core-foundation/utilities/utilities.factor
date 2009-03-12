! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math assocs kernel sequences byte-arrays strings
hashtables alien destructors
core-foundation.numbers core-foundation.strings
core-foundation.arrays core-foundation.dictionaries
core-foundation.data core-foundation ;
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