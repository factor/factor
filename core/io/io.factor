! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: hashtables generic kernel math namespaces make sequences
continuations destructors assocs ;
IN: io

GENERIC: stream-read1 ( stream -- elt )
GENERIC: stream-read ( n stream -- seq )
GENERIC: stream-read-until ( seps stream -- seq sep/f )
GENERIC: stream-read-partial ( n stream -- seq )
GENERIC: stream-readln ( stream -- str/f )

GENERIC: stream-write1 ( elt stream -- )
GENERIC: stream-write ( seq stream -- )
GENERIC: stream-flush ( stream -- )
GENERIC: stream-nl ( stream -- )

GENERIC: stream-seek ( n stream -- )

: stream-print ( str stream -- ) [ stream-write ] keep stream-nl ;

! Default streams
SYMBOL: input-stream
SYMBOL: output-stream
SYMBOL: error-stream

: readln ( -- str/f ) input-stream get stream-readln ;
: read1 ( -- elt ) input-stream get stream-read1 ;
: read ( n -- seq ) input-stream get stream-read ;
: read-until ( seps -- seq sep/f ) input-stream get stream-read-until ;
: read-partial ( n -- seq ) input-stream get stream-read-partial ;
: seek ( n -- ) input-stream get stream-seek ;

: write1 ( elt -- ) output-stream get stream-write1 ;
: write ( seq -- ) output-stream get stream-write ;
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

: print ( str -- ) output-stream get stream-print ;

: bl ( -- ) " " write ;

: lines ( stream -- seq )
    [ [ readln dup ] [ ] [ drop ] produce ] with-input-stream ;

<PRIVATE

: each-morsel ( handler: ( data -- ) reader: ( -- data ) -- )
    [ dup ] compose swap [ drop ] while ; inline

PRIVATE>

: each-line ( quot -- )
    [ readln ] each-morsel ; inline

: contents ( stream -- seq )
    [
        [ 65536 read-partial dup ]
        [ ] [ drop ] produce concat f like
    ] with-input-stream ;

: each-block ( quot: ( block -- ) -- )
    [ 8192 read-partial ] each-morsel ; inline

: stream-copy ( in out -- )
    [ [ [ write ] each-block ] with-output-stream ]
    curry with-input-stream ;
