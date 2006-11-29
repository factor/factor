! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: io-internals kernel ;

: <file-reader> ( path -- stream ) open-read <reader> ;
: <file-writer> ( path -- stream ) open-write <writer> ;
: <file-r/w> ( path -- stream ) open-r/w dup <fd-stream> ;
