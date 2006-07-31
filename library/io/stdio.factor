! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: errors generic hashtables kernel namespaces sequences
strings styles ;

! Default stream
SYMBOL: stdio

: close ( -- ) stdio get stream-close ;

: readln ( -- string/f ) stdio get stream-readln ;
: read1 ( -- char/f ) stdio get stream-read1 ;
: read ( count -- string ) stdio get stream-read ;

: write1 ( char -- ) stdio get stream-write1 ;
: write ( string -- ) stdio get stream-write ;
: flush ( -- ) stdio get stream-flush ;

: terpri ( -- ) stdio get stream-terpri ;
: format ( string style -- ) stdio get stream-format ;

: with-nesting ( style quot -- )
    swap stdio get with-nested-stream ;

: tabular-output ( grid style quot -- )
    swap stdio get with-stream-table ;

: with-style ( style quot -- )
    swap dup hash-empty?
    [ drop call ] [ stdio get with-stream-style ] if ;

: print ( string -- ) stdio get stream-print ;

: with-stream* ( stream quot -- )
    [ swap stdio set call ] with-scope ; inline

: with-stream ( stream quot -- )
    swap [ [ close ] cleanup ] with-stream* ; inline

: bl ( -- ) " " write ;

: write-object ( string object -- )
    presented associate format ;

: write-outliner ( string object content -- )
    outline associate [ write-object ] with-nesting ;
