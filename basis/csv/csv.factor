! Copyright (C) 2007, 2008 Phil Dawes
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences io namespaces make combinators
unicode.categories io.files combinators.short-circuit ;
IN: csv

SYMBOL: delimiter

CHAR: , delimiter set-global

<PRIVATE

: delimiter> ( -- delimiter ) delimiter get ; inline
    
DEFER: quoted-field ( -- endchar )
    
: trim-whitespace ( str -- str )
    [ blank? ] trim ; inline

: skip-to-field-end ( -- endchar )
  "\n" delimiter> suffix read-until nip ; inline
  
: not-quoted-field ( -- endchar )
    "\"\n" delimiter> suffix read-until
    dup {
        { CHAR: "    [ 2drop quoted-field ] }
        { delimiter> [ swap trim-whitespace % ] }
        { CHAR: \n   [ swap trim-whitespace % ] }
        { f          [ swap trim-whitespace % ] }
    } case ;
  
: maybe-escaped-quote ( -- endchar )
    read1 dup {
        { CHAR: "    [ , quoted-field ] }
        { delimiter> [ ] }
        { CHAR: \n   [ ] }
        [ 2drop skip-to-field-end ]
    } case ;
  
: quoted-field ( -- endchar )
    "\"" read-until
    drop % maybe-escaped-quote ;

: field ( -- sep string )
    [ not-quoted-field ] "" make  ;

: (row) ( -- sep )
    field , 
    dup delimiter> = [ drop (row) ] when ;

: row ( -- eof? array[string] )
    [ (row) ] { } make ;

: (csv) ( -- )
    row
    dup [ empty? ] all? [ drop ] [ , ] if
    [ (csv) ] when ;
  
PRIVATE>

: csv-row ( stream -- row )
    [ row nip ] with-input-stream ;

: csv ( stream -- rows )
    [ [ (csv) ] { } make ] with-input-stream
    dup last { "" } = [ but-last ] when ;

: file>csv ( path encoding -- csv )
    <file-reader> csv ;

: with-delimiter ( ch quot -- )
    [ delimiter ] dip with-variable ; inline

<PRIVATE

: needs-escaping? ( cell -- ? )
    [ { [ "\n\"" member? ] [ delimiter get = ] } 1|| ] any? ; inline

: escape-quotes ( cell -- cell' )
    [
        [
            [ , ]
            [ dup CHAR: " = [ , ] [ drop ] if ] bi
        ] each
    ] "" make ; inline

: enclose-in-quotes ( cell -- cell' )
    "\"" dup surround ; inline
    
: escape-if-required ( cell -- cell' )
    dup needs-escaping?
    [ escape-quotes enclose-in-quotes ] when ; inline

PRIVATE>
    
: write-row ( row -- )
    [ delimiter get write1 ]
    [ escape-if-required write ] interleave nl ; inline
    
: write-csv ( rows stream -- )
    [ [ write-row ] each ] with-output-stream ;

: csv>file ( rows path encoding -- ) <file-writer> write-csv ;
