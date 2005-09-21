! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: errors generic kernel lists math namespaces sequences
strings ;

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
    f swap stream-format ;

: stream-terpri ( stream -- )
    "\n" over stream-write stream-finish ;

: stream-print ( string stream -- )
    [ stream-write ] keep stream-terpri ;

: (stream-copy) ( in out -- )
    4096 pick stream-read
    [ over stream-write (stream-copy) ] [ 2drop ] ifte* ;

: stream-copy ( in out -- )
    [ 2dup (stream-copy) ] [ stream-close stream-close ] cleanup ;

! Think '/dev/null'.
TUPLE: null-stream ;
M: null-stream stream-flush drop ;
M: null-stream stream-finish drop ;
M: null-stream stream-readln drop f ;
M: null-stream stream-read 2drop f ;
M: null-stream stream-read1 drop f ;
M: null-stream stream-write1 2drop ;
M: null-stream stream-format 3drop ;
M: null-stream stream-close drop ;

! Sometimes, we want to have a delegating stream that uses stdio
! words.
TUPLE: wrapper-stream scope ;

C: wrapper-stream ( stream -- stream )
    2dup set-delegate [
        >r [ stdio set ] make-hash r> set-wrapper-stream-scope
    ] keep ;

: with-wrapper ( stream quot -- )
    >r wrapper-stream-scope r> bind ; inline
