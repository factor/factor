! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types io.encodings io.encodings.utf16 kernel ;
IN: io.encodings.utf16n

! Native-order UTF-16

SINGLETON: utf16n

: utf16n ( -- descriptor )
    little-endian? utf16le utf16be ? ; foldable

M: utf16n <decoder> drop utf16n <decoder> ;

M: utf16n <encoder> drop utf16n <encoder> ;
