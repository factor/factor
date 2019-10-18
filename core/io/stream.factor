! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: errors hashtables generic kernel math namespaces
sequences strings ;

GENERIC: stream-close ( stream -- )
GENERIC: set-timeout ( n stream -- )
GENERIC: stream-readln ( stream -- str )
GENERIC: stream-read1 ( stream -- ch/f )
GENERIC: stream-read ( n stream -- str/f )
GENERIC: stream-read-until ( seps stream -- str/f sep/f )
GENERIC: stream-write1 ( ch stream -- )
GENERIC: stream-write ( str stream -- )
GENERIC: stream-flush ( stream -- )
GENERIC: stream-nl ( stream -- )
GENERIC: stream-format ( str style stream -- )
GENERIC: with-nested-stream ( quot style stream -- )
GENERIC: with-stream-style ( quot style stream -- )
GENERIC: stream-write-table ( table-cells style stream -- )
GENERIC: make-table-cell ( quot style stream -- table-cell )

: stream-print ( str stream -- )
    [ stream-write ] keep stream-nl ;

: (stream-copy) ( in out -- )
    64 1024 * pick stream-read
    [ over stream-write (stream-copy) ] [ 2drop ] if* ;

: stream-copy ( in out -- )
    [ 2dup (stream-copy) ] [ stream-close stream-close ] cleanup ;
