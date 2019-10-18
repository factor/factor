! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: errors hashtables generic kernel math namespaces
sequences strings ;

GENERIC: stream-close ( stream -- )
GENERIC: set-timeout ( n stream -- )
GENERIC: stream-readln ( stream -- str )
GENERIC: stream-read1 ( stream -- ch/f )
GENERIC: stream-read ( n stream -- str/f )
GENERIC: stream-write1 ( ch stream -- )
GENERIC: stream-write ( str stream -- )
GENERIC: stream-flush ( stream -- )
GENERIC: stream-terpri ( stream -- )
GENERIC: stream-format ( str style stream -- )
GENERIC: with-nested-stream ( quot style stream -- )
GENERIC: with-stream-table ( grid quot style stream -- )
GENERIC: with-stream-style ( quot style stream -- )

: stream-print ( str stream -- )
    [ stream-write ] keep stream-terpri ;

: (stream-copy) ( in out -- )
    4096 pick stream-read
    [ over stream-write (stream-copy) ] [ 2drop ] if* ;

: stream-copy ( in out -- )
    [ 2dup (stream-copy) ] [ stream-close stream-close ] cleanup ;
