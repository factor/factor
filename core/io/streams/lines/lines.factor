! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.streams.lines
USING: io.encodings.latin1 io.encodings ;

TUPLE: line-reader cr ;

: <line-reader> ( stream -- new-stream )
    latin1 <decoded> ;
