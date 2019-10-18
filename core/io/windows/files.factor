! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: io-internals kernel nonblocking-io ;

: <file-reader> ( path -- stream ) t f open-file 0 <win32-file> <reader> ;
: <file-writer> ( path -- stream ) f t open-file 0 <win32-file> <writer> ;
: <file-r/w> ( path -- stream ) t t open-file handle>duplex-stream ;
