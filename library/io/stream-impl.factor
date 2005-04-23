! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: io-internals errors hashtables kernel stdio strings
namespaces generic ;

IN: stdio
DEFER: stdio

IN: streams

! fd-streams read/write port objects, which are elaborated in
! io-internals.factor.

TUPLE: fd-stream in out ;

M: fd-stream stream-write-attr ( str style stream -- )
    nip fd-stream-out blocking-write ;

M: fd-stream stream-readln ( stream -- str )
    dup fd-stream-out [ blocking-flush ] when*
    fd-stream-in dup [ blocking-read-line ] when ;

M: fd-stream stream-read ( count stream -- str )
    fd-stream-in dup [ blocking-read ] [ nip ] ifte ;

M: fd-stream stream-flush ( stream -- )
    fd-stream-out [ blocking-flush ] when* ;

M: fd-stream stream-auto-flush ( stream -- )
    drop ;

M: fd-stream stream-close ( stream -- )
    dup fd-stream-out [ dup blocking-flush close-port ] when*
    fd-stream-in [ close-port ] when* ;

: <file-reader> ( path -- stream )
    t f open-file <fd-stream> ;

: <file-writer> ( path -- stream )
    f t open-file <fd-stream> ;

: (fcopy) ( from to -- )
    #! Copy the contents of the fd-stream 'from' to the
    #! fd-stream 'to'. Use fcopy; this word does not close
    #! streams.
    fd-stream-out >r fd-stream-in r> blocking-copy ;

: fcopy ( from to -- )
    #! Copy the contents of the fd-stream 'from' to the
    #! fd-stream 'to'.
    [
        2dup (fcopy)
    ] [
        -rot stream-close stream-close rethrow
    ] catch ;

: init-stdio ( -- )
    #! Opens file descriptors 0, 1.
    stdin stdout <fd-stream> <stdio-stream> stdio set ;
