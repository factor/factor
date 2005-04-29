! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: streams
USE: io-internals

: <file-reader> ( path -- stream ) open-read <reader> ;
: <file-writer> ( path -- stream ) open-write <writer> ;
