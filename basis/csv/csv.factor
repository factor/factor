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
    "\n" swap suffix ; inline

: field-end ( -- str sep )
    delimiter> (field-end) read-until ; inline

DEFER: quoted-field

MEMO: (quoted-field) ( delimiter -- delimiter' )
    "\"\n" swap suffix ; inline

: maybe-escaped-quote ( quoted? -- endchar )
    read1 dup {
        { CHAR: "    [ over [ , ] [ drop ] if quoted-field ] }
        { delimiter> [ ] }
        { CHAR: \n   [ ] } ! Error: newline inside string?
        [ [ , f maybe-escaped-quote ] when ]
    } case nip ;

: quoted-field ( -- endchar )
    "\"" read-until
    drop % t maybe-escaped-quote ;

: ?trim ( string -- string' )
    dup { [ first blank? ] [ last blank? ] } 1||
    [ [ blank? ] trim ] when ;

: field ( -- sep string )
    delimiter> (quoted-field) read-until
    dup CHAR: " = [
        over empty?
        [ 2drop [ quoted-field ] "" make ]
        [ drop field-end [ "\"" glue ] dip swap ?trim ]
        if
    ] [
        swap [ "" ] [ ?trim ] if-empty
    ] if ;

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
