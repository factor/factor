! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: strings arrays hashtables assocs sequences
xml.writer xml.utilities kernel namespaces ;
IN: cocoa.plists

GENERIC: >plist ( obj -- tag )

M: string >plist "string" build-tag ;

M: array >plist
    [ >plist ] map "array" build-tag* ;

M: hashtable >plist
    >alist [ >r "key" build-tag r> >plist ] assoc-map concat
    "dict" build-tag* ;

: build-plist ( obj -- tag )
    >plist 1array "plist" build-tag*
    dup { { "version" "1.0" } } update ;

: plist>string ( obj -- string )
    build-plist build-xml xml>string ;
