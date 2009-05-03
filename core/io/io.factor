! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: hashtables generic kernel math namespaces make sequences
continuations destructors assocs ;
IN: io

SYMBOLS: +byte+ +character+ ;

GENERIC: stream-element-type ( stream -- type )

GENERIC: stream-read1 ( stream -- elt )
GENERIC: stream-read ( n stream -- seq )
GENERIC: stream-read-until ( seps stream -- seq sep/f )
GENERIC: stream-read-partial ( n stream -- seq )
GENERIC: stream-readln ( stream -- str/f )

GENERIC: stream-write1 ( elt stream -- )
GENERIC: stream-write ( seq stream -- )
GENERIC: stream-flush ( stream -- )
GENERIC: stream-nl ( stream -- )

ERROR: bad-seek-type type ;
SINGLETONS: seek-absolute seek-relative seek-end ;
GENERIC: stream-seek ( n seek-type stream -- )

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
: seek-input ( n seek-type -- ) input-stream get stream-seek ;
: seek-output ( n seek-type -- ) output-stream get stream-seek ;

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

: stream-lines ( stream -- seq )
    [ [ readln dup ] [ ] produce nip ] with-input-stream ;

: lines ( -- seq )
    input-stream get stream-lines ;

<PRIVATE

: each-morsel ( handler: ( data -- ) reader: ( -- data ) -- )
    [ dup ] compose swap while drop ; inline

PRIVATE>

: each-line ( quot -- )
    [ readln ] each-morsel ; inline

: stream-contents ( stream -- seq )
    [
        [ 65536 read-partial dup ] [ ] produce nip concat f like
    ] with-input-stream ;

: contents ( -- seq )
    input-stream get stream-contents ;

: each-block ( quot: ( block -- ) -- )
    [ 8192 read-partial ] each-morsel ; inline

: stream-copy ( in out -- )
    [ [ [ write ] each-block ] with-output-stream ]
    curry with-input-stream ;
