! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: files
USING: io-internals errors hashtables kernel stdio strings
namespaces generic ;

! We need this early during bootstrap.
: path+ ( path path -- path )
    #! Combine two paths. This will be implemented later.
    "/" swap cat3 ;

IN: stdio
DEFER: stdio

IN: streams

TUPLE: fd-stream in out ;

M: fd-stream fwrite-attr ( str style stream -- )
    nip fd-stream-out blocking-write ;

M: fd-stream freadln ( stream -- str )
    fd-stream-in dup [ blocking-read-line ] when ;

M: fd-stream fread# ( count stream -- str )
    fd-stream-in dup [ blocking-read# ] [ nip ] ifte ;

M: fd-stream fflush ( stream -- )
    fd-stream-out [ blocking-flush ] when* ;

M: fd-stream fauto-flush ( stream -- )
    drop ;

M: fd-stream fclose ( stream -- )
    dup fd-stream-out [ dup blocking-flush close-port ] when*
    fd-stream-in [ close-port ] when* ;

: <file-reader> ( path -- stream )
    t f open-file <fd-stream> ;

: <file-writer> ( path -- stream )
    f t open-file <fd-stream> ;

: init-stdio ( -- )
    stdin stdout <fd-stream> <stdio-stream> stdio set ;

: (fcopy) ( from to -- )
    #! Copy the contents of the fd-stream 'from' to the
    #! fd-stream 'to'. Use fcopy; this word does not close
    #! streams.
    fd-stream-out >r fd-stream-in r> blocking-copy ;

: fcopy ( from to -- )
    #! Copy the contents of the fd-stream 'from' to the
    #! fd-stream 'to'.
    [ 2dup (fcopy) ] [ -rot fclose fclose rethrow ] catch ;

: resource-path ( -- path )
    "resource-path" get [ "." ] unless* ;

: <resource-stream> ( path -- stream )
    resource-path swap path+ <file-reader> ;
