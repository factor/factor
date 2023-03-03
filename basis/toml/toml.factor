! Copyright (C) 2019 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors assocs hashtables kernel make math.parser peg
peg.parsers regexp sequences splitting strings.parser ;

IN: toml

ERROR: duplicate-key key ;

ERROR: unknown-value value ;

<PRIVATE

! FIXME: key = 1234abcd # should error!

TUPLE: table name array? entries ;

TUPLE: entry key value ;

: boolean-parser ( -- parser )
    "true" token [ drop t ] action
    "false" token [ drop f ] action
    2choice ;

: digits ( parser -- parser )
    "_" token [ drop f ] action 2choice repeat1 [ sift ] action ;

: sign ( -- parser )
    "+" token "-" token 2choice ;

: hexdigit ( -- parser )
    [
        CHAR: 0 CHAR: 9 range ,
        CHAR: a CHAR: f range ,
        CHAR: A CHAR: F range ,
    ] choice* ;

: hex ( -- parser )
    "0x" token hide hexdigit digits 2seq [ first hex> ] action ;

: decdigit ( -- parser )
    CHAR: 0 CHAR: 9 range ;

: dec ( -- parser )
    decdigit digits [ dec> ] action ;

: octdigit ( -- parser )
    CHAR: 0 CHAR: 7 range ;

: oct ( -- parser )
    "0o" token hide octdigit digits 2seq [ first oct> ] action ;

: bindigit ( -- parser )
    CHAR: 0 CHAR: 1 range ;

: bin ( -- parser )
    "0b" token hide bindigit digits 2seq [ first bin> ] action ;

: integer-parser ( -- parser )
    hex oct bin dec 4choice ;

: float ( -- parser )
    [
        sign optional ,
        decdigit digits optional ,
        "." token ,
        decdigit digits optional ,
        "e" token "E" token 2choice
        sign optional
        decdigit digits optional 3seq optional ,
    ] seq* [ unclip-last append "" concat-as string>number ] action ;

: +inf ( -- parser )
    "+" token optional "inf" token 2seq [ drop 1/0. ] action ;

: -inf ( -- parser )
    "-inf" token [ drop -1/0. ] action ;

: nan ( -- parser )
    sign optional "nan" token 2seq
    [ drop NAN: 8000000000000 ] action ;

: float-parser ( -- parser )
    float +inf -inf nan 4choice ;

: escaped ( -- parser )
    "\\" token hide [ "btnfr\"\\" member-eq? ] satisfy 2seq
    [ first escape ] action ;

: unicode ( -- parser )
    "\\u" token hide hexdigit 4 exactly-n 2seq
    "\\U" token hide hexdigit 8 exactly-n 2seq
    2choice [ first hex> ] action ;

: basic-string ( -- parser )
    escaped unicode [ "\"\n" member? not ] satisfy 3choice repeat0
    "\"" dup surrounded-by ;

: literal-string ( -- parser )
    [ "'\n" member? not ] satisfy repeat0
    "'" dup surrounded-by ;

: single-string ( -- parser )
    basic-string literal-string 2choice [ "" like ] action ;

: multi-basic-string ( -- parser )
    escaped unicode [ CHAR: \" = not ] satisfy 3choice repeat0
    "\"\"\"" dup surrounded-by ;

: multi-literal-string ( -- parser )
    [ CHAR: ' = not ] satisfy repeat0
    "'''" dup surrounded-by ;

: multi-string ( -- parser )
    multi-basic-string multi-literal-string 2choice [
        "" like "\n" ?head drop
        R/ \\[ \t\r\n]*\n[ \t\r\n]*/m "" re-replace
    ] action ;

: string-parser ( -- parser )
    multi-string single-string 2choice ;

: date-parser ( -- parser )
    [
        decdigit 4 exactly-n ,
        "-" token ,
        decdigit 2 exactly-n ,
        "-" token ,
        decdigit 2 exactly-n ,
    ] seq* [ "" concat-as ] action ;

: time-parser ( -- parser )
    [
        decdigit 2 exactly-n ,
        ":" token ,
        decdigit 2 exactly-n ,
        ":" token ,
        decdigit 2 exactly-n ,
        "." token decdigit repeat1 2seq optional ,
    ] seq* [ "" concat-as ] action ;

: timezone-parser ( -- parser )
    "Z" token
    "-" token
    decdigit 2 exactly-n ":" token
    decdigit 2 exactly-n 4seq [ "" concat-as ] action
    2choice ;

: datetime-parser ( -- parser )
    [
        date-parser ,
        "T" token " " token 2choice ,
        time-parser ,
        timezone-parser optional ,
    ] seq* [ "" concat-as ] action ;

: space ( -- parser )
    [ " \t" member? ] satisfy repeat0 ;

: whitespace ( -- parser )
    [ " \t\r\n" member? ] satisfy repeat0 ;

DEFER: value-parser

: array-parser ( -- parser )
    [
        "[" token hide ,
        whitespace hide ,
        value-parser
        whitespace "," token whitespace pack list-of ,
        whitespace hide ,
        "]" token hide ,
    ] seq* [ first { } like ] action ;

DEFER: key-value-parser

DEFER: update-toml

: inline-table-parser ( -- parser )
    [
        "{" token hide ,
        whitespace hide ,
        key-value-parser
        whitespace "," token whitespace pack list-of ,
        whitespace hide ,
        "}" token hide ,
    ] seq* [
        first [ length <hashtable> ] keep [ update-toml ] each
    ] action ;

: value-parser ( -- parser )
    [
        [
            boolean-parser ,
            datetime-parser ,
            date-parser ,
            time-parser ,
            float-parser ,
            integer-parser ,
            string-parser ,
            array-parser ,
            inline-table-parser ,
        ] choice*
    ] delay ;

: name-parser ( -- parser )
    [
        CHAR: A CHAR: Z range ,
        CHAR: a CHAR: z range ,
        CHAR: 0 CHAR: 9 range ,
        "_" token [ first ] action ,
        "-" token [ first ] action ,
    ] choice* repeat1 [ "" like ] action single-string 2choice ;

: comment-parser ( -- parser )
    [
        space hide ,
        "#" token ,
        [ CHAR: \n = not ] satisfy repeat0 ,
    ] seq* [ drop f ] action ;

: key-parser ( -- parser )
    name-parser "." token list-of [ { } like ] action ;

: key-value-parser ( -- parser )
    [
        space hide ,
        key-parser ,
        space hide ,
        "=" token hide ,
        space hide ,
        value-parser ,
        comment-parser optional hide ,
    ] seq* [ first2 entry boa ] action ;

: line-parser ( -- parser )
    "\n" token "\r\n" token 2choice ;

:: table-name-parser ( begin end -- parser )
    [
        begin token hide ,
        space hide ,
        name-parser
        space "." token space pack list-of
        [ { } like ] action ,
        space hide ,
        end token hide ,
        comment-parser optional hide ,
    ] seq* ;

: table-parser ( -- parser )
    [
        space hide ,
        "[[" "]]" table-name-parser [ t suffix! ] action
        "[" "]" table-name-parser [ f suffix! ] action
        2choice ,
        whitespace hide ,
        key-value-parser line-parser list-of optional ,
    ] seq* [ first2 [ first2 ] dip table boa ] action ;

: toml-parser ( -- parser )
    [
        whitespace hide ,
        [
            comment-parser ,
            table-parser ,
            key-value-parser ,
        ] choice* whitespace list-of ,
        whitespace hide ,
    ] seq* [ first sift { } like ] action ;

: check-no-key ( key assoc -- key assoc )
    2dup at* nip [ over duplicate-key ] when ;

: deep-at ( keys assoc -- value )
    swap [
        over ?at [ nip ] [
            H{ } clone [ spin check-no-key set-at ] keep
        ] if
    ] each ;

GENERIC: update-toml ( assoc entry -- assoc )

M: entry update-toml
    [ key>> unclip-last [ over deep-at ] dip ] [ value>> ] bi
    spin check-no-key set-at ;

M: table update-toml
    [ name>> unclip-last [ over deep-at ] dip ]
    [ entries>> [ H{ } clone ] dip [ update-toml ] each spin ]
    [ array?>> [ push-at ] [ check-no-key set-at ] if ] tri ;

PEG: parse-toml ( string -- ast ) toml-parser ;

PRIVATE>

: toml> ( string -- assoc )
    [ H{ } clone ] dip parse-toml [ update-toml ] each ;
