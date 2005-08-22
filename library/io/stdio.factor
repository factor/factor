! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: errors generic kernel lists namespaces strings styles ;

: flush  ( -- )              stdio get stream-flush ;
: readln ( -- string/f )     stdio get stream-readln ;
: read1  ( -- char/f )       stdio get stream-read1 ;
: read   ( count -- string ) stdio get stream-read ;
: write  ( string -- )       stdio get stream-write ;
: write1 ( char -- )         stdio get stream-write1 ;
: format ( string style -- ) stdio get stream-format ;
: print  ( string -- )       stdio get stream-print ;
: terpri ( -- )              stdio get stream-terpri ;
: close  ( -- )              stdio get stream-close ;

: write-icon ( resource -- )
    #! Write an icon. Eg, /library/icons/File.png
    icon swons unit "" swap format ;

: write-object ( string object -- )
    presented swons unit format ;

: with-stream ( stream quot -- )
    #! Close the stream no matter what happens.
    [ swap stdio set [ close rethrow ] catch ] with-scope ;

: with-stream* ( stream quot -- )
    #! Close the stream if there is an error.
    [
        swap stdio set
        [ [ close rethrow ] when* ] catch
    ] with-scope ;

: contents ( stream -- string )
    #! Read the entire stream into a string.
    4096 <sbuf> [ stream-copy ] keep >string ;
