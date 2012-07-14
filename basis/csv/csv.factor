! Copyright (C) 2007, 2008 Phil Dawes
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences io namespaces make combinators
unicode.categories io.files combinators.short-circuit
io.streams.string fry memoize ;
IN: csv

SYMBOL: delimiter

CHAR: , delimiter set-global

<PRIVATE

: delimiter> ( -- delimiter ) delimiter get ; inline

MEMO: (field-end) ( delimiter -- delimiter' )
    "\n" swap suffix ;

: skip-to-field-end ( -- endchar )
    delimiter> (field-end) read-until nip ; inline

DEFER: quoted-field

MEMO: (quoted-field) ( delimiter -- delimiter' )
    "\"\n" swap suffix ;

: not-quoted-field ( -- endchar )
    delimiter> (quoted-field) read-until
    dup {
        { CHAR: "    [ 2drop quoted-field ] }
        { delimiter> [ swap [ blank? ] trim % ] }
        { CHAR: \n   [ swap [ blank? ] trim % ] }
        { f          [ swap [ blank? ] trim % ] }
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
    f delimiter> '[ dup _ = ]
    [ drop field , ] do while ;

: row ( -- eof? array[string] )
    [ (row) ] { } make ;

: (csv) ( -- )
    [ dup [ empty? ] all? [ drop ] [ , ] if ]
    [ row ] do while ;

PRIVATE>

: csv-row ( stream -- row )
    [ row nip ] with-input-stream ;

: csv ( stream -- rows )
    [ [ (csv) ] { } make ] with-input-stream
    dup last { "" } = [ but-last ] when ;

: string>csv ( string -- csv )
    <string-reader> csv ;

: file>csv ( path encoding -- csv )
    <file-reader> csv ;

: with-delimiter ( ch quot -- )
    [ delimiter ] dip with-variable ; inline

<PRIVATE

: needs-escaping? ( cell -- ? )
    delimiter> '[
        dup "\n\"" member? [ drop t ] [ _ = ] if
    ] any? ; inline

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
    delimiter> '[ _ write1 ]
    [ escape-if-required write ] interleave nl ; inline

<PRIVATE

: (write-csv) ( rows -- )
    [ write-row ] each ;

PRIVATE>

: write-csv ( rows stream -- )
    [ (write-csv) ] with-output-stream ;

: csv>string ( csv -- string )
    [ (write-csv) ] with-string-writer ;

: csv>file ( rows path encoding -- ) <file-writer> write-csv ;
