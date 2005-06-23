! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: errors kernel lists namespaces generic strings ;

: flush      ( -- )              stdio get stream-flush ;
: read-line  ( -- string )       stdio get stream-readln ;
: read1      ( -- char )         stdio get stream-read1 ;
: read       ( count -- string ) stdio get stream-read ;
: write      ( string -- )       stdio get stream-write ;
: write-attr ( string style -- ) stdio get stream-write-attr ;
: print      ( string -- )       stdio get stream-print ;
: terpri     ( -- )              "\n" write ;
: crlf       ( -- )              "\r\n" write ;
: bl         ( -- )              " " write ;
: close      ( -- )              stdio get stream-close ;

: write-icon ( resource -- )
    #! Write an icon. Eg, /library/icons/File.png
    "icon" swons unit "" swap write-attr ;

: with-stream ( stream quot -- )
    #! Close the stream no matter what happends.
    [ swap stdio set  [ close rethrow ] catch ] with-scope ;

: with-stream* ( stream quot -- )
    #! Close the stream if there is an error.
    [
        swap stdio set
        [ [ close rethrow ] when* ] catch
    ] with-scope ;
