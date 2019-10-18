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
GENERIC: stream-write1 ( ch stream -- )
GENERIC: stream-write ( str stream -- )
GENERIC: stream-flush ( stream -- )
GENERIC: stream-nl ( stream -- )
GENERIC: stream-format ( str style stream -- )
GENERIC: with-nested-stream ( quot style stream -- )
GENERIC: with-stream-style ( quot style stream -- )
GENERIC: stream-write-table ( table-cells style stream -- )
GENERIC: make-table-cell ( quot style stream -- table-cell )

: stream-print ( str stream -- )
    [ stream-write ] keep stream-nl ;

: (stream-copy) ( in out -- )
    64 1024 * pick stream-read
    [ over stream-write (stream-copy) ] [ 2drop ] if* ;

: stream-copy ( in out -- )
    [ 2dup (stream-copy) ] [ stream-close stream-close ] cleanup ;

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

: with-nesting ( style quot -- )
    swap stdio get with-nested-stream ;

: tabular-output ( style quot -- )
    swap >r { } make r> stdio get stream-write-table ;

: with-row ( quot -- ) { } make , ;

: with-cell ( quot -- ) H{ } stdio get make-table-cell , ;

: write-cell ( str -- ) [ write ] with-cell ;

: with-style ( style quot -- )
    swap dup assoc-empty?
    [ drop call ] [ stdio get with-stream-style ] if ;

: print ( string -- ) stdio get stream-print ;

: with-stream* ( stream quot -- )
    stdio swap with-variable ; inline

: with-stream ( stream quot -- )
    swap [ [ close ] cleanup ] with-stream* ; inline

: bl ( -- ) " " write ;

: write-object ( str obj -- )
    presented associate format ;

: lines-loop ( -- ) readln [ , lines-loop ] when* ;

: lines ( stream -- seq )
    [ [ lines-loop ] { } make ] with-stream ;

: contents ( stream -- str )
    2048 <sbuf> [ stream-copy ] keep >string ;
