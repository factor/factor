! Copyright (C) 2003, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators continuations destructors kernel
math namespaces sequences ;
IN: io

SYMBOLS: +byte+ +character+ ;

GENERIC: stream-element-type ( stream -- type )

GENERIC: stream-read1 ( stream -- elt )
GENERIC: stream-read ( n stream -- seq )
GENERIC: stream-read-until ( seps stream -- seq sep/f )
GENERIC: stream-read-partial ( n stream -- seq )
GENERIC: stream-readln ( stream -- str/f )

GENERIC: stream-write1 ( elt stream -- )
GENERIC: stream-write ( data stream -- )
GENERIC: stream-flush ( stream -- )
GENERIC: stream-nl ( stream -- )

ERROR: bad-seek-type type ;

SINGLETONS: seek-absolute seek-relative seek-end ;

GENERIC: stream-tell ( stream -- n )
GENERIC: stream-seek ( n seek-type stream -- )

: stream-print ( str stream -- ) [ stream-write ] [ stream-nl ] bi ;

! Default streams
SYMBOL: input-stream
SYMBOL: output-stream
SYMBOL: error-stream

: readln ( -- str/f ) input-stream get stream-readln ;
: read1 ( -- elt ) input-stream get stream-read1 ;
: read ( n -- seq ) input-stream get stream-read ;
: read-until ( seps -- seq sep/f ) input-stream get stream-read-until ;
: read-partial ( n -- seq ) input-stream get stream-read-partial ;
: tell-input ( -- n ) input-stream get stream-tell ;
: tell-output ( -- n ) output-stream get stream-tell ;
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
    swapd [ with-output-stream* ] curry with-input-stream* ; inline

: with-streams ( input output quot -- )
    #! We have to dispose of the output stream first, so that
    #! if both streams point to the same FD, we get to flush the
    #! buffer before closing the FD.
    swapd [ with-output-stream ] curry with-input-stream ; inline

: print ( str -- ) output-stream get stream-print ;

: bl ( -- ) " " write ;

: each-morsel ( ..a handler: ( ..a data -- ..b ) reader: ( ..b -- ..a data ) -- ..a )
    [ dup ] compose swap while drop ; inline

<PRIVATE

: (stream-element-exemplar) ( type -- exemplar )
    {
        { +byte+ [ B{ } ] }
        { +character+ [ "" ] }
    } case ; inline

: stream-element-exemplar ( stream -- exemplar )
    stream-element-type (stream-element-exemplar) ; inline

PRIVATE>

: each-stream-line ( stream quot: ( ... line -- ... ) -- )
    swap [ stream-readln ] curry each-morsel ; inline

: each-line ( quot: ( ... line -- ... ) -- )
    input-stream get swap each-stream-line ; inline

: stream-lines ( stream -- seq )
    [ [ ] collector [ each-stream-line ] dip { } like ] with-disposal ;

: lines ( -- seq )
    input-stream get stream-lines ; inline

: each-stream-block ( stream quot: ( ... block -- ... ) -- )
    swap 65536 swap [ stream-read-partial ] 2curry each-morsel ; inline

: each-block ( quot: ( ... block -- ... ) -- )
    input-stream get swap each-stream-block ; inline

: stream-contents ( stream -- seq )
    [
        [ [ ] collector [ each-stream-block ] dip { } like ]
        [ stream-element-exemplar concat-as ] bi
    ] with-disposal ;

: contents ( -- seq )
    input-stream get stream-contents ; inline

: stream-copy ( in out -- )
    [ [ [ write ] each-block ] with-output-stream ]
    curry with-input-stream ;
