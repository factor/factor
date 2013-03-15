! Copyright (C) 2007, 2008 Phil Dawes
! See http://factorcode.org/license.txt for BSD license.
USING: combinators fry io io.files io.streams.string kernel
make math memoize namespaces sbufs sequences sequences.private
unicode.categories ;
IN: csv

SYMBOL: delimiter

CHAR: , delimiter set-global

<PRIVATE

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

: (stream-read-row) ( delimiter stream field-end quoted-field -- delimiter sep/f fields )
    [ dup [ 2dup = ] ] 3dip '[ drop _ _ _ field ] produce ;

: (stream-read-csv) ( stream -- )
    delimiter get
    [ dup [ empty? ] all? [ drop ] [ , ] if ]
    rot pick field-delimiters
    '[ _ _ _ (stream-read-row) ] do while drop ;

PRIVATE>

: stream-read-row ( stream -- row )
    delimiter get swap over field-delimiters
    (stream-read-row) 2nip ; inline

: read-row ( -- row )
    input-stream get stream-read-row ; inline

: stream-read-csv ( stream -- rows )
    [ (stream-read-csv) ] { } make
    dup last { "" } = [ but-last ] when ; inline

: read-csv ( -- rows )
    input-stream get stream-read-csv ; inline

: string>csv ( string -- csv )
    [ read-csv ] with-string-reader ;

: file>csv ( path encoding -- csv )
    [ read-csv ] with-file-reader ;

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

: (stream-write-row) ( row delimiter stream -- )
    [ '[ _ _ stream-write1 ] ] 2keep
    '[ _ _ escape-if-required ] interleave nl ; inline

PRIVATE>

: stream-write-row ( row stream -- )
    delimiter get swap (stream-write-row) ; inline

: write-row ( row -- )
    output-stream get stream-write-row ; inline

: stream-write-csv ( rows stream -- )
    delimiter get swap '[ _ _ (stream-write-row) ] each ;

: write-csv ( rows -- )
    output-stream get stream-write-csv ;

: csv>string ( csv -- string )
    [ write-csv ] with-string-writer ;

: csv>file ( rows path encoding -- )
    [ write-csv ] with-file-writer ;
