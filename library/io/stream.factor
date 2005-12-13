! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: errors hashtables generic kernel math namespaces
sequences strings ;

SYMBOL: stdio

! Stream protocol.
GENERIC: stream-flush  ( stream -- )
GENERIC: stream-finish ( stream -- )
GENERIC: stream-readln ( stream -- string )
GENERIC: stream-read1  ( stream -- char/f )
GENERIC: stream-read   ( count stream -- string )
GENERIC: stream-write1 ( char stream -- )
GENERIC: stream-format ( string style stream -- )
GENERIC: stream-close  ( stream -- )
GENERIC: set-timeout   ( timeout stream -- )

: stream-write ( string stream -- )
    H{ } swap stream-format ;

: stream-terpri ( stream -- )
    "\n" over stream-write stream-finish ;

: stream-print ( string stream -- )
    [ stream-write ] keep stream-terpri ;

: (stream-copy) ( in out -- )
    4096 pick stream-read
    [ over stream-write (stream-copy) ] [ 2drop ] if* ;

: stream-copy ( in out -- )
    [ 2dup (stream-copy) ] [ stream-close stream-close ] cleanup ;

! Think '/dev/null'.
M: f stream-flush drop ;
M: f stream-finish drop ;
M: f stream-readln drop f ;
M: f stream-read 2drop f ;
M: f stream-read1 drop f ;
M: f stream-write1 2drop ;
M: f stream-format 3drop ;
M: f stream-close drop ;
