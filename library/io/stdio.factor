! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: stdio
USING: errors kernel lists namespaces streams generic strings ;

SYMBOL: stdio

: flush      ( -- )              stdio get fflush ;
: read       ( -- string )       stdio get freadln ;
: read1      ( count -- string ) stdio get fread1 ;
: read#      ( count -- string ) stdio get fread# ;
: write      ( string -- )       stdio get fwrite ;
: write-attr ( string style -- ) stdio get fwrite-attr ;
: print      ( string -- )       stdio get fprint ;
: terpri     ( -- )              "\n" write ;
: close      ( -- )              stdio get fclose ;

: write-icon ( resource -- )
    #! Write an icon. Eg, /library/icons/File.png
    "icon" swons unit "" swap write-attr ;

: with-stream ( stream quot -- )
    [ swap stdio set  [ close rethrow ] catch ] with-scope ;

: with-string ( quot -- str )
    #! Execute a quotation, and push a string containing all
    #! text printed by the quotation.
    1024 <string-output> [
        call stdio get stream>str
    ] with-stream ;

TUPLE: stdio-stream delegate ;

M: stdio-stream fauto-flush ( -- )
    stdio-stream-delegate fflush ;

M: stdio-stream fclose ( -- )
    drop ;
