! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.streams.plain
USING: io.encodings.latin1 io.encodings ;

: <plain-writer> ( stream -- new-stream )
    latin1 <encoded> ; 
