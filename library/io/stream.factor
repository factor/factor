! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: stdio
DEFER: stdio
IN: streams
USING: errors generic kernel lists math namespaces strings ;

GENERIC: stream-flush      ( stream -- )
GENERIC: stream-auto-flush ( stream -- )
GENERIC: stream-readln     ( stream -- string )
GENERIC: stream-read       ( count stream -- string )
GENERIC: stream-write-attr ( string style stream -- )
GENERIC: stream-close      ( stream -- )

: stream-read1 ( stream -- char/f )
    1 swap stream-read
    dup f-or-"" [ drop f ] [ 0 swap str-nth ] ifte ;

: stream-write ( string stream -- )
    f swap stream-write-attr ;

: stream-print ( string stream -- )
    [ stream-write ] keep
    [ "\n" swap stream-write ] keep
    stream-auto-flush ;

! A stream that builds a string of all text written to it.
TUPLE: string-output buf ;

M: string-output stream-write-attr ( string style stream -- )
    nip string-output-buf sbuf-append ;

M: string-output stream-close ( stream -- ) drop ;
M: string-output stream-flush ( stream -- ) drop ;
M: string-output stream-auto-flush ( stream -- ) drop ;

: stream>str ( stream -- string )
    #! Returns the string written to the given string output
    #! stream.
    string-output-buf sbuf>str ;

C: string-output ( size -- stream )
    #! Creates a new stream for writing to a string buffer.
    [ >r <sbuf> r> set-string-output-buf ] keep ;

! Sometimes, we want to have a delegating stream that uses stdio
! words.
TUPLE: wrapper-stream delegate scope ;

C: wrapper-stream ( stream -- stream )
    2dup set-wrapper-stream-delegate
    [
        >r <namespace> [ stdio set ] extend r>
        set-wrapper-stream-scope
    ] keep ;

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
