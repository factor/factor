! Copyright (C) 2007, 2008 Phil Dawes
! See http://factorcode.org/license.txt for BSD license.
USING: combinators fry io io.files io.streams.string kernel
make math memoize namespaces sbufs sequences sequences.private
unicode.categories ;
IN: csv

SYMBOL: delimiter

CHAR: , delimiter set-global

<PRIVATE

: delimiter> ( -- delimiter ) delimiter get ; inline

MEMO: field-delimiters ( delimiter -- field-end quoted-field )
    [ "\n" swap suffix ] [ "\"\n" swap suffix ] bi ; inline

DEFER: quoted-field

: maybe-escaped-quote ( delimeter stream quoted? -- delimiter stream endchar/f )
    2over stream-read1 swap over =
    [ nip ] [
        {
            { CHAR: "    [ [ CHAR: " , ] when quoted-field ] }
            { CHAR: \n   [ ] } ! Error: newline inside string?
            [ [ , drop f maybe-escaped-quote ] when* ]
        } case
     ] if ; inline recursive

: quoted-field ( delimiter stream -- delimiter stream endchar/f )
    "\"" over stream-read-until drop % t maybe-escaped-quote ;

: ?trim ( string -- string' )
    dup length [ drop "" ] [
        over first-unsafe blank?
        [ drop t ] [ 1 - over nth-unsafe blank? ] if
        [ [ blank? ] trim ] when
    ] if-zero ; inline

: field ( delimiter stream field-end quoted-field -- delimiter sep/f field )
    pick stream-read-until dup CHAR: " = [
        drop
        [ drop [ quoted-field nip ] "" make ]
        [
            swap rot stream-read-until
            [ "\"" glue ] dip swap ?trim
        ]
        if-empty
    ] [ [ 2drop ] 2dip swap ?trim ] if ;

: (row) ( delimiter stream field-end quoted-field -- delimiter sep/f fields )
    [ dup [ 2dup = ] ] 3dip
    [ [ drop ] 3dip field ] 3curry produce ;

: row ( delimiter -- delimiter sep/f fields )
    input-stream get over field-delimiters (row) ;

: (csv) ( -- )
    delimiter>
    [ dup [ empty? ] all? [ drop ] [ , ] if ]
    input-stream get pick field-delimiters
    [ (row) ] 3curry do while drop ;

PRIVATE>

: read-row ( stream -- row )
    [ delimiter> row 2nip ] with-input-stream ;

: read-csv ( stream -- rows )
    [ [ (csv) ] { } make ] with-input-stream
    dup last { "" } = [ but-last ] when ;

: string>csv ( string -- csv )
    <string-reader> read-csv ;

: file>csv ( path encoding -- csv )
    <file-reader> read-csv ;

: with-delimiter ( ch quot -- )
    [ delimiter ] dip with-variable ; inline

<PRIVATE

: needs-escaping? ( cell delimiter -- ? )
    '[ dup "\n\"" member? [ drop t ] [ _ = ] if ] any? ; inline

: escape-quotes ( cell stream -- )
    CHAR: " over stream-write1 swap [
        [ over stream-write1 ]
        [ dup CHAR: " = [ over stream-write1 ] [ drop ] if ] bi
    ] each CHAR: " swap stream-write1 ; inline

: escape-if-required ( cell delimiter stream -- )
    [ dupd needs-escaping? ] dip
    [ escape-quotes ] [ stream-write ] bi-curry if ; inline

: (write-row) ( row delimiter stream -- )
    [ '[ _ _ stream-write1 ] ] 2keep
    '[ _ _ escape-if-required ] interleave nl ; inline

PRIVATE>

: write-row ( row -- )
    delimiter> output-stream get (write-row) ; inline

<PRIVATE

: (write-csv) ( rows -- )
    delimiter> output-stream get '[ _ _ (write-row) ] each ;

PRIVATE>

: write-csv ( rows stream -- )
    [ (write-csv) ] with-output-stream ;

: csv>string ( csv -- string )
    [ (write-csv) ] with-string-writer ;

: csv>file ( rows path encoding -- )
    <file-writer> write-csv ;
