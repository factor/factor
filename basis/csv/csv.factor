! Copyright (C) 2007, 2008 Phil Dawes, 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: combinators io io.files io.streams.string kernel make
math namespaces sequences sequences.private unicode ;
IN: csv

SYMBOL: delimiter

CHAR: , delimiter set-global

<PRIVATE

MEMO: field-delimiters ( delimiter -- field-seps quote-seps )
    [ "\r\n" swap prefix ] [ "\r\"\n" swap prefix ] bi ; inline

DEFER: quoted-field,

: maybe-escaped-quote ( delimeter stream quoted? -- delimiter stream sep/f )
    2over stream-read1 tuck =
    [ nip ] [
        {
            { CHAR: \"    [ [ CHAR: \" , ] when quoted-field, ] }
            { CHAR: \n   [ ] } ! Error: cr inside string?
            { CHAR: \r   [ ] } ! Error: lf inside string?
            [ [ , drop f maybe-escaped-quote ] when* ]
        } case
    ] if ; inline recursive

: quoted-field, ( delimiter stream -- delimiter stream sep/f )
    "\"" over stream-read-until drop % t maybe-escaped-quote ;

: quoted-field ( delimiter stream -- sep/f field )
    [ quoted-field, 2nip ] "" make ;

: ?trim ( string -- string' )
    dup length [ drop "" ] [
        over first-unsafe unicode:blank?
        [ drop t ] [ 1 - over nth-unsafe unicode:blank? ] if
        [ [ unicode:blank? ] trim ] when
    ] if-zero ; inline

: continue-field ( delimiter stream field-seps seq -- sep/f field )
    spin stream-read-until [ "\"" glue ] dip
    swap ?trim nipd ; inline

: field ( delimiter stream field-seps quote-seps -- sep/f field )
    pick stream-read-until dup CHAR: \" = [
        drop [ drop quoted-field ] [ continue-field ] if-empty
    ] [ 3nipd swap ?trim ] if ;

: (stream-read-row) ( delimiter stream field-end quoted-field -- sep/f fields )
    [ [ dup '[ dup _ = ] ] keep ] 3dip
    '[ drop _ _ _ _ field ] produce ; inline

: (stream-read-csv) ( stream -- )
    [ dup [ empty? ] all? [ drop ] [ , ] if ]
    delimiter get rot over field-delimiters
    '[ _ _ _ _ (stream-read-row) ] do while ;

PRIVATE>

: stream-read-row ( stream -- row )
    delimiter get tuck field-delimiters
    (stream-read-row) nip ; inline

: read-row ( -- row )
    input-stream get stream-read-row ; inline

: stream-read-csv ( stream -- rows )
    [ (stream-read-csv) ] { } make
    dup ?last { "" } = [ but-last ] when ; inline

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
    '[ dup "\n\"\r" member? [ drop t ] [ _ = ] if ] any? ; inline

: escape-quotes ( cell stream -- )
    CHAR: \" over stream-write1 swap [
        [ over stream-write1 ]
        [ dup CHAR: \" = [ over stream-write1 ] [ drop ] if ] bi
    ] each CHAR: \" swap stream-write1 ;

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
