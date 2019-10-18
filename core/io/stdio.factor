! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: errors generic assocs kernel namespaces sequences
strings styles structure hashtables ;

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
    [ swap stdio set call ] with-scope ; inline

: with-stream ( stream quot -- )
    swap [ [ close ] cleanup ] with-stream* ; inline

: bl ( -- ) " " write ;

: write-object ( str obj -- )
    presented associate format ;

: write-editable-object ( path printer -- )
    [ 2dup presented-printer set presented-path set ] H{ } make-assoc
    [ >r field-path r> call ] with-nesting ;
