! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: stdio
DEFER: stdio
IN: streams
USING: errors kernel namespaces strings generic lists ;

GENERIC: fflush      ( stream -- )
GENERIC: fauto-flush ( stream -- )
GENERIC: freadln     ( stream -- string )
GENERIC: fread#      ( count stream -- string )
GENERIC: fwrite-attr ( string style stream -- )
GENERIC: fclose      ( stream -- )

: fread1 ( stream -- char/f )
    1 swap fread#
    dup f-or-"" [ drop f ] [ 0 swap str-nth ] ifte ;

: fwrite ( string stream -- )
    f swap fwrite-attr ;

: fprint ( string stream -- )
    [ fwrite ] keep
    [ "\n" swap fwrite ] keep
    fauto-flush ;

! A stream that builds a string of all text written to it.
TUPLE: string-output buf ;

M: string-output fwrite-attr ( string style stream -- )
    nip string-output-buf sbuf-append ;

M: string-output fclose ( stream -- ) drop ;
M: string-output fflush ( stream -- ) drop ;
M: string-output fauto-flush ( stream -- ) drop ;

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
