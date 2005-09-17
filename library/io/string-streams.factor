! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: io kernel math namespaces sequences strings ;

! String buffers support the stream output protocol.
M: sbuf stream-write1 push ;
M: sbuf stream-format rot nappend drop ;
M: sbuf stream-close drop ;
M: sbuf stream-flush drop ;
M: sbuf stream-finish drop ;

: string-out ( quot -- str )
    [ 512 <sbuf> stdio set call stdio get >string ] with-scope ;

! Reversed string buffers support the stream input protocol.
M: sbuf stream-read1 ( sbuf -- char/f )
    dup empty? [ drop f ] [ pop ] ifte ;

M: sbuf stream-read ( count sbuf -- string )
    dup empty? [
        2drop f
    ] [
        swap over length min empty-sbuf
        [ [ drop dup pop ] inject drop ] keep
    ] ifte ;

: <string-reader> ( string -- stream )
    <reversed> >sbuf <line-reader> ;

: string-in ( str quot -- )
    [ swap <string-reader> stdio set call ] with-scope ;
