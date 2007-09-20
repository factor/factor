! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: hashtables generic kernel math namespaces
sequences strings continuations assocs io.styles sbufs ;

GENERIC: stream-close ( stream -- )
GENERIC: set-timeout ( n stream -- )
GENERIC: stream-readln ( stream -- str )
GENERIC: stream-read1 ( stream -- ch/f )
GENERIC: stream-read ( n stream -- str/f )
GENERIC: stream-read-until ( seps stream -- str/f sep/f )
GENERIC: stream-read-partial ( max stream -- str/f )
GENERIC: stream-write1 ( ch stream -- )
GENERIC: stream-write ( str stream -- )
GENERIC: stream-flush ( stream -- )
GENERIC: stream-nl ( stream -- )
GENERIC: stream-format ( str style stream -- )
GENERIC: make-span-stream ( style stream -- stream' )
GENERIC: make-block-stream ( style stream -- stream' )
GENERIC: make-cell-stream ( style stream -- stream' )
GENERIC: stream-write-table ( table-cells style stream -- )

: stream-print ( str stream -- )
    [ stream-write ] keep stream-nl ;

: (stream-copy) ( in out -- )
    64 1024 * pick stream-read
    [ over stream-write (stream-copy) ] [ 2drop ] if* ;

: stream-copy ( in out -- )
    [ 2dup (stream-copy) ] [ stream-close stream-close ] [ ]
    cleanup ;

! Default stream
SYMBOL: stdio

: close ( -- ) stdio get stream-close ;

: readln ( -- str/f ) stdio get stream-readln ;
: read1 ( -- ch/f ) stdio get stream-read1 ;
: read ( n -- str/f ) stdio get stream-read ;
: read-until ( seps -- str/f sep/f ) stdio get stream-read-until ;

: write1 ( ch -- ) stdio get stream-write1 ;
: write ( str -- ) stdio get stream-write ;
: flush ( -- ) stdio get stream-flush ;

: nl ( -- ) stdio get stream-nl ;
: format ( str style -- ) stdio get stream-format ;

: with-stream* ( stream quot -- )
    stdio swap with-variable ; inline

: with-stream ( stream quot -- )
    swap [ [ close ] [ ] cleanup ] with-stream* ; inline

: tabular-output ( style quot -- )
    swap >r { } make r> stdio get stream-write-table ; inline

: with-row ( quot -- )
    { } make , ; inline

: with-cell ( quot -- )
    H{ } stdio get make-cell-stream
    [ swap with-stream ] keep , ; inline

: write-cell ( str -- )
    [ write ] with-cell ; inline

: with-style ( style quot -- )
    swap dup assoc-empty? [
        drop call
    ] [
        stdio get make-span-stream swap with-stream
    ] if ; inline

: with-nesting ( style quot -- )
    >r stdio get make-block-stream r> with-stream ; inline

: print ( string -- ) stdio get stream-print ;

: bl ( -- ) " " write ;

: write-object ( str obj -- )
    presented associate format ;

: lines-loop ( -- ) readln [ , lines-loop ] when* ;

: lines ( stream -- seq )
    [ [ lines-loop ] { } make ] with-stream ;

: contents ( stream -- str )
    2048 <sbuf> [ stream-copy ] keep >string ;
