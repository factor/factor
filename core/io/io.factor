! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: hashtables generic kernel math namespaces make sequences
continuations destructors assocs ;
IN: io

GENERIC: stream-readln ( stream -- str/f )
GENERIC: stream-read1 ( stream -- ch/f )
GENERIC: stream-read ( n stream -- str/f )
GENERIC: stream-read-until ( seps stream -- str/f sep/f )
GENERIC: stream-read-partial ( n stream -- str/f )
GENERIC: stream-write1 ( ch stream -- )
GENERIC: stream-write ( str stream -- )
GENERIC: stream-flush ( stream -- )
GENERIC: stream-nl ( stream -- )

: stream-print ( str stream -- )
    [ stream-write ] keep stream-nl ;

: (stream-copy) ( in out -- )
    64 1024 * pick stream-read-partial
    [ over stream-write (stream-copy) ] [ 2drop ] if* ;

: stream-copy ( in out -- )
    [ 2dup (stream-copy) ] [ dispose dispose ] [ ]
    cleanup ;

! Default streams
SYMBOL: input-stream
SYMBOL: output-stream
SYMBOL: error-stream

: readln ( -- str/f ) input-stream get stream-readln ;
: read1 ( -- ch/f ) input-stream get stream-read1 ;
: read ( n -- str/f ) input-stream get stream-read ;
: read-until ( seps -- str/f sep/f ) input-stream get stream-read-until ;
: read-partial ( n -- str/f ) input-stream get stream-read-partial ;

: write1 ( ch -- ) output-stream get stream-write1 ;
: write ( str -- ) output-stream get stream-write ;
: flush ( -- ) output-stream get stream-flush ;

: nl ( -- ) output-stream get stream-nl ;

: with-input-stream* ( stream quot -- )
    input-stream swap with-variable ; inline

: with-input-stream ( stream quot -- )
    [ with-input-stream* ] curry with-disposal ; inline

: with-output-stream* ( stream quot -- )
    output-stream swap with-variable ; inline

: with-output-stream ( stream quot -- )
    [ with-output-stream* ] curry with-disposal ; inline

: with-streams* ( input output quot -- )
    [ output-stream set input-stream set ] prepose with-scope ; inline

: with-streams ( input output quot -- )
    [ [ with-streams* ] 3curry ]
    [ [ drop dispose dispose ] 3curry ] 3bi
    [ ] cleanup ; inline

: print ( string -- ) output-stream get stream-print ;

: bl ( -- ) " " write ;

: lines ( stream -- seq )
    [ [ readln dup ] [ ] [ drop ] produce ] with-input-stream ;

: each-line ( quot -- )
    [ [ readln dup ] ] dip [ drop ] while ; inline

: contents ( stream -- str )
    [
        [ 65536 read dup ] [ ] [ drop ] produce concat f like
    ] with-input-stream ;
