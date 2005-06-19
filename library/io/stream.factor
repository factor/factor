! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: files
USING: kernel strings sequences ;

! We need this early during bootstrap.
: path+ ( path path -- path )
    #! Combine two paths. This will be implemented later.
    "/" swap append3 ;

IN: stdio
DEFER: stdio

IN: streams
USING: errors generic lists math namespaces sequences ;

! Stream protocol.
GENERIC: stream-flush      ( stream -- )
GENERIC: stream-auto-flush ( stream -- )
GENERIC: stream-readln     ( stream -- string )
GENERIC: stream-read       ( count stream -- string )
GENERIC: stream-read1      ( stream -- char/f )
GENERIC: stream-write-attr ( string style stream -- )
GENERIC: stream-close      ( stream -- )
GENERIC: set-timeout       ( timeout stream -- )

: stream-write ( string stream -- )
    f swap stream-write-attr ;

: stream-print ( string stream -- )
    [ stream-write ] keep
    [ "\n" swap stream-write ] keep
    stream-auto-flush ;

! Think '/dev/null'.
TUPLE: null-stream ;
M: null-stream stream-flush drop ;
M: null-stream stream-auto-flush drop ;
M: null-stream stream-readln drop f ;
M: null-stream stream-read 2drop f ;
M: null-stream stream-read1 drop f ;
M: null-stream stream-write-attr 3drop ;
M: null-stream stream-close drop ;

! String buffers support the stream output protocol.
M: sbuf stream-write-attr nip sbuf-append ;
M: sbuf stream-close drop ;
M: sbuf stream-flush drop ;
M: sbuf stream-auto-flush drop ;

! Sometimes, we want to have a delegating stream that uses stdio
! words.
TUPLE: wrapper-stream scope ;

C: wrapper-stream ( stream -- stream )
    2dup set-delegate [
        >r <namespace> [ stdio set ] extend r>
        set-wrapper-stream-scope
    ] keep ;

: with-wrapper ( stream quot -- )
    >r wrapper-stream-scope r> bind ;

! Combine an input and output stream into one, and flush the
! stream more often.
TUPLE: duplex-stream in out flush? ;

M: duplex-stream stream-flush
    duplex-stream-out stream-flush ;

M: duplex-stream stream-auto-flush
    dup duplex-stream-flush? [
        duplex-stream-out stream-flush
    ] [
        drop
    ] ifte ;

M: duplex-stream stream-readln
    duplex-stream-in stream-readln ;

M: duplex-stream stream-read
    duplex-stream-in stream-read ;

M: duplex-stream stream-read1
    duplex-stream-in stream-read1 ;

M: duplex-stream stream-write-attr
    duplex-stream-out stream-write-attr ;

M: duplex-stream stream-close
    duplex-stream-out stream-close ;

M: duplex-stream set-timeout
    2dup
    duplex-stream-in set-timeout
    duplex-stream-out set-timeout ;

! Reading lines and counting line numbers.
SYMBOL: line-number
SYMBOL: parser-stream

: next-line ( -- str )
    parser-stream get stream-readln
    line-number [ 1 + ] change ;

: read-lines ( stream quot -- )
    #! Apply a quotation to each line as its read. Close the
    #! stream.
    swap [
        parser-stream set 0 line-number set [ next-line ] while
    ] [
        parser-stream get stream-close rethrow
    ] catch ;

! Standard actions protocol for presentations output to
! attributed streams.
: <actions> ( path alist -- alist )
    #! For each element of the alist, change the value to
    #! path " " value
    [ uncons >r swap " " r> append3 cons ] map-with ;

DEFER: <file-reader>

: resource-path ( -- path )
    "resource-path" get [ "." ] unless* ;

: <resource-stream> ( path -- stream )
    #! Open a file path relative to the Factor source code root.
    resource-path swap path+ <file-reader> ;

: (stream-copy) ( in out -- )
    4096 pick stream-read [
        over stream-write (stream-copy)
    ] [
        2drop
    ] ifte* ;

: stream-copy ( in out -- )
    [
        2dup (stream-copy)
    ] [
        >r stream-close stream-close r> [ rethrow ] when*
    ] catch ;
