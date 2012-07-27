! Copyright (C) 2007, 2008 Phil Dawes
! See http://factorcode.org/license.txt for BSD license.
USING: combinators fry io io.files io.streams.string kernel
make math memoize namespaces sequences sequences.private
unicode.categories ;
IN: csv

SYMBOL: delimiter

CHAR: , delimiter set-global

<PRIVATE

: delimiter> ( -- delimiter ) delimiter get ; inline

MEMO: (field-end) ( delimiter -- delimiter' )
    "\n" swap suffix ; inline

MEMO: (quoted-field) ( delimiter -- delimiter' )
    "\"\n" swap suffix ; inline

DEFER: quoted-field

: maybe-escaped-quote ( delimeter quoted? -- delimiter endchar )
    read1 pick over =
    [ nip ] [
        {
            { CHAR: "    [ [ CHAR: " , ] when quoted-field ] }
            { CHAR: \n   [ ] } ! Error: newline inside string?
            [ [ , drop f maybe-escaped-quote ] when* ]
        } case
     ] if ;

: quoted-field ( delimiter -- delimiter endchar )
    "\"" read-until drop % t maybe-escaped-quote ;

: ?trim ( string -- string' )
    dup length [ drop "" ] [
        over first-unsafe blank?
        [ drop t ] [ 1 - over nth-unsafe blank? ] if
        [ [ blank? ] trim ] when
    ] if-zero ; inline

: field ( delimiter -- delimiter sep string )
    dup (quoted-field) read-until
    dup CHAR: " = [
        drop
        [ [ quoted-field ] "" make ]
        [
            over (field-end) read-until
            [ "\"" glue ] dip swap ?trim
        ]
        if-empty
    ] [ swap ?trim ] if ;

: (row) ( delimiter -- delimiter sep )
    f [ 2dup = ] [ drop field , ] do while ;

: row ( delimiter -- delimiter eof? array[string] )
    [ (row) ] { } make ;

: (csv) ( -- )
    delimiter>
    [ dup [ empty? ] all? [ drop ] [ , ] if ]
    [ row ] do while drop ;

PRIVATE>

: csv-row ( stream -- row )
    [ delimiter> row 2nip ] with-input-stream ;

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

: (write-row) ( row delimiter -- )
    '[ _ write1 ]
    [ escape-if-required write ] interleave nl ; inline

PRIVATE>

: write-row ( row -- )
    delimiter> (write-row) ; inline

<PRIVATE

: (write-csv) ( rows -- )
    delimiter> '[ _ (write-row) ] each ;

PRIVATE>

: write-csv ( rows stream -- )
    [ (write-csv) ] with-output-stream ;

: csv>string ( csv -- string )
    [ (write-csv) ] with-string-writer ;

: csv>file ( rows path encoding -- ) <file-writer> write-csv ;
