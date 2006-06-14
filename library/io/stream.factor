! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: errors hashtables generic kernel math namespaces
sequences strings ;

GENERIC: stream-close ( stream -- )
GENERIC: set-timeout ( timeout stream -- )
GENERIC: stream-readln ( stream -- string )
GENERIC: stream-read1 ( stream -- char/f )
GENERIC: stream-read ( count stream -- string )
GENERIC: stream-write1 ( char stream -- )
GENERIC: stream-write ( string stream -- )
GENERIC: stream-flush ( stream -- )
GENERIC: stream-terpri ( stream -- )
GENERIC: stream-format ( string style stream -- )
GENERIC: with-nested-stream ( quot style stream -- )
GENERIC: with-stream-table ( grid quot style stream -- )

: stream-print ( string stream -- )
    [ stream-write ] keep stream-terpri ;

: (stream-copy) ( in out -- )
    4096 pick stream-read
    [ over stream-write (stream-copy) ] [ 2drop ] if* ;

: stream-copy ( in out -- )
    [ 2dup (stream-copy) ] [ stream-close stream-close ] cleanup ;
