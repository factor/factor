! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: errors hashtables generic kernel namespaces strings
styles ;

SYMBOL: stdio

: close ( -- ) stdio get stream-close ;

: readln ( -- string/f )     stdio get stream-readln ;
: read1 ( -- char/f )       stdio get stream-read1 ;
: read ( count -- string ) stdio get stream-read ;

: write1 ( char -- ) stdio get stream-write1 ;
: write ( string -- ) stdio get stream-write ;
: flush ( -- ) stdio get stream-flush ;

: break ( -- ) stdio get stream-break ;
: terpri ( -- ) stdio get stream-terpri ;
: format ( string style -- ) stdio get stream-format ;
: with-nesting ( style quot -- ) stdio get with-nested-stream ;

: print ( string -- ) stdio get stream-print ;

: write-outliner ( string object quot -- )
    [ outline set presented set ] make-hash format terpri ;

: with-stream ( stream quot -- )
    #! Close the stream no matter what happens.
    [ swap stdio set [ close ] cleanup ] with-scope ; inline

: with-stream* ( stream quot -- )
    #! Close the stream if there is an error.
    [ swap stdio set [ close rethrow ] recover ] with-scope ;
    inline
