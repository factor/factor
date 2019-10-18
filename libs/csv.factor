REQUIRES: libs/state-parser ;
IN: csv
USING: kernel sequences state-parser namespaces io ;

! parsing CSV

: skip-white ( -- )
    [ get-char " \t" member? not ] skip-until ;

: csv-string ( -- string )
    next [
        get-char CHAR: " =
        [ get-next CHAR: " = dup [ next ] when not ]
        [ f ] if
    ] take-until next skip-white ;

: take-chars ( chars -- string )
    [ get-char over member? ] take-until nip ;

: field ( -- string )
    skip-white get-char CHAR: " =
    [ csv-string ] [ ",\n" take-chars ] if ;

: (line) ( last-char -- )
    CHAR: \n = 
    get-char not or
    [ field , get-char next* (line) ] unless ;
: line ( -- array[string] ) [ get-char (line) ] { } make ;

: (csv) ( -- )
   get-char [ line , (csv) ] when ;
: csv ( stream -- csv )
    [ [ (csv) ] { } make ] state-parse ;

: string>csv ( string -- csv )
    <string-reader> csv ;

! Writing CSV

: any-member? ( seq possible-members -- ? )
    [ swap member? not ] all-with? not ;

: write-quote ( -- )
    CHAR: " write1 ;

: write-string ( string -- )
    write-quote
    [ dup CHAR: " = [ CHAR: " write1 ] when write1 ] each
    write-quote ;

: write-field ( string -- )
    dup "\t \n\r\"," any-member?
    [ write-string ] [ write ] if ;

: write-csv-line ( array -- )
    [ CHAR: , write1 ] [ write-field ] interleave nl ;

: write-csv ( csv -- )
    [ write-csv-line ] each ;

: csv>string ( csv -- string )
    [ write-csv ] string-out ;
