! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings io.encodings.utf16 kernel alien.accessors ;
IN: io.encodings.utf16n

! Native-order UTF-16

SINGLETON: utf16n

: utf16n ( -- descriptor )
    B{ 1 0 0 0 } 0 alien-unsigned-4 1 = utf16le utf16be ? ; foldable

M: utf16n <decoder> drop utf16n <decoder> ;

M: utf16n <encoder> drop utf16n <encoder> ;
