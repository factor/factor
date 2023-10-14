! Copyright (C) 2019 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors ascii assocs hashtables io.encodings.utf8
io.files kernel make math.parser peg peg.parsers regexp
sequences splitting strings.parser ;

! https://github.com/toml-lang/toml/blob/main/toml.abnf

IN: toml

ERROR: duplicate-key key ;

ERROR: unknown-value value ;

<PRIVATE

TUPLE: table name array? ;

TUPLE: entry key value ;

: check-no-key ( key assoc -- key assoc )
    2dup at* nip [ over duplicate-key ] when ;

: entries-at ( table keys -- key entries )
    unclip-last -rot [
        over ?at [ nip ] [
            H{ } clone [ spin check-no-key set-at ] keep
        ] if
    ] each ;

GENERIC: update-toml ( root table entry -- root table' )

M: entry update-toml
    dupd [ key>> entries-at ] [ value>> ] bi
    -rot check-no-key set-at ;

M: table update-toml
    nip dupd [ name>> entries-at ] [ array?>> ] bi
    H{ } clone [
        swap [ -rot push-at ] [ -rot check-no-key set-at ] if
    ] keep ;

: ws ( -- parser )
    [ " \t" member? ] satisfy repeat0 ;

: newline ( -- parser )
    "\n" token "\r\n" token 2choice ;

: boolean-parser ( -- parser )
    "true" token [ drop t ] action
    "false" token [ drop f ] action
    2choice ;

: digits ( parser -- parser )
    "_" token [ drop f ] action 2choice repeat1 [ sift ] action ;

: sign ( -- parser )
    "+" token "-" token 2choice ;

: hexdigit ( -- parser )
    CHAR: 0 CHAR: 9 range
    CHAR: a CHAR: f range
    CHAR: A CHAR: F range 3choice ;

: hex-parser ( -- parser )
    sign optional "0x" token hexdigit digits 3seq
    [ "" concat-as string>number ] action ;

: decdigit ( -- parser )
    CHAR: 0 CHAR: 9 range ;

: dec-parser ( -- parser )
    sign optional decdigit digits 2seq
    [ "" concat-as string>number ] action ;

: octdigit ( -- parser )
    CHAR: 0 CHAR: 7 range ;

: oct-parser ( -- parser )
    sign optional "0o" token octdigit digits 3seq
    [ "" concat-as string>number ] action ;

: bindigit ( -- parser )
    CHAR: 0 CHAR: 1 range ;

: bin-parser ( -- parser )
    sign optional "0b" token bindigit digits 3seq
    [ "" concat-as string>number ] action ;

: integer-parser ( -- parser )
    hex-parser oct-parser bin-parser dec-parser 4choice ;

: exponent ( -- parser )
    "e" token "E" token 2choice sign optional
    decdigit digits optional 3seq
    [ "" concat-as ] action ;

: normal-float ( -- parser )
    [ sign optional , decdigit digits , exponent , ] seq*
    [ sign optional , decdigit digits , "." token , decdigit digits , exponent optional , ] seq*
    2choice [ "" concat-as string>number ] action ;

: +inf ( -- parser )
    "+inf" token "inf" token 2choice [ drop 1/0. ] action ;

: -inf ( -- parser )
    "-inf" token [ drop -1/0. ] action ;

: nan ( -- parser )
    sign optional "nan" token 2seq [ drop 0/0. ] action ;

: float-parser ( -- parser )
    normal-float +inf -inf nan 4choice ;

: number-parser ( -- parser )
    +inf -inf nan
    [ blank? not ] satisfy repeat1 [ string>number ] action
    4choice ;

: escaped ( -- parser )
    "\\" token hide [ "\"\\befnrt" member-eq? ] satisfy 2seq
    [ first escape ] action ;

: unicode ( -- parser )
    "\\u" token hide hexdigit 4 exactly-n 2seq
    "\\U" token hide hexdigit 8 exactly-n 2seq
    2choice [ first hex> ] action ;

: hexescape ( -- parser )
    "\\x" token hide hexdigit 2 exactly-n 2seq
    "\\X" token hide hexdigit 2 exactly-n 2seq
    2choice [ first hex> ] action ;

: basic-string ( -- parser )
    escaped unicode hexescape [ "\"\n" member? not ] satisfy
    4choice repeat0 "\"" dup surrounded-by ;

: literal-string ( -- parser )
    [ "'" member? not ] satisfy repeat0 "'" dup surrounded-by ;

: single-string ( -- parser )
    basic-string literal-string 2choice [ "" like ] action ;

: multi-basic-string ( -- parser )
    escaped unicode [ CHAR: \" = not ] satisfy 3choice repeat0
    "\"\"\"" dup surrounded-by ;

: multi-literal-string ( -- parser )
    [ CHAR: ' = not ] satisfy repeat0 "'''" dup surrounded-by ;

: multi-string ( -- parser )
    multi-basic-string multi-literal-string 2choice [
        "" like "\n" ?head drop
        R/ \\[ \t\r\n]*\n[ \t\r\n]*/m "" re-replace
    ] action ;

: string-parser ( -- parser )
    multi-string single-string 2choice ;

: non-ascii ( -- parser )
    0x80 0xd7ff range 0xe000 0x10ffff range 2choice ;

: comment-char ( -- parser )
    0x01 0x09 range 0x0e 0x7f range non-ascii 3choice ;

: comment ( -- parser )
    "#" token comment-char repeat0 2seq hide ;

: ws-comment-newline ( -- parser )
    ws comment optional 2seq newline list-of ;

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

: separator ( -- parser )
    "," token comment optional 2seq ;

DEFER: value-parser

: array-value-parser ( -- parser )
    ws-comment-newline hide
    value-parser
    ws-comment-newline hide 3seq [ first ] action ;

: array-parser ( -- parser )
    [
        "[" token hide ,
        array-value-parser separator list-of optional ,
        separator optional hide ,
        ws-comment-newline hide ,
        "]" token hide ,
    ] seq* [ first { } like ] action ;

DEFER: key-value-parser

: inline-table-key-value ( -- parser )
    ws-comment-newline hide
    key-value-parser
    ws-comment-newline hide 3seq [ first ] action ;

: inline-table-parser ( -- parser )
    [
        "{" token hide ,
        inline-table-key-value separator list-of ,
        separator optional hide ,
        ws-comment-newline hide ,
        "}" token hide ,
    ] seq* [
        first [ length <hashtable> ] keep [ update-toml ] each
    ] action ;

: value-parser ( -- parser )
    [
        [
            array-parser ,
            boolean-parser ,
            datetime-parser ,
            date-parser ,
            time-parser ,
            float-parser ,
            integer-parser ,
            string-parser ,
            inline-table-parser ,
        ] choice*
    ] delay ;

: unquoted-key ( -- parser )
    [
        CHAR: A CHAR: Z range ,
        CHAR: a CHAR: z range ,
        CHAR: 0 CHAR: 9 range ,
        [ "_-\xb2\xb3\xb9\xbc\xbd\xbe" member? ] satisfy ,
        0xC0 0XD6 range ,
        0xD8 0xF6 range ,
        0xF8 0x37D range ,
        0x37F 0x1FFF range ,
        0x200C 0x200D range ,
        0x203F 0x2040 range ,
        0x2070 0x218F range ,
        0x2460 0x24FF range ,
        0x2C00 0x2FEF range ,
        0x3001 0xD7FF range ,
        0xF900 0xFDCF range ,
        0xFDF0 0xFFFFD range ,
        0x10000 0xEFFFF range ,
    ] choice* repeat1 [ "" like ] action single-string 2choice ;

: quoted-key ( -- parser )
    multi-string single-string 2choice ;

: simple-key ( -- parser )
    unquoted-key quoted-key 2choice ;

: key-parser ( -- parser )
    simple-key ws "." token ws 3seq list-of ;

: key-value-parser ( -- parser )
    [
        key-parser ,
        ws hide ,
        "=" token hide ,
        ws hide ,
        value-parser ,
    ] seq* [ first2 entry boa ] action ;

:: table-name-parser ( begin end array? -- parser )
    [
        begin token hide ,
        ws hide ,
        key-parser ,
        ws hide ,
        end token hide ,
    ] seq* [ first array? table boa ] action ;

: array-table ( -- parser )
    "[[" "]]" t table-name-parser ;

: std-table ( -- parser )
    "[" "]" f table-name-parser ;

: table-parser ( -- parser )
    array-table std-table 2choice ;

PEG: parse-toml ( string -- ast )
    ws hide key-value-parser ws hide comment optional hide 4seq
    ws hide table-parser ws hide comment optional hide 4seq
    ws hide comment optional hide 2seq
    3choice newline list-of [ { } concat-as ] action ;

PRIVATE>

: toml> ( string -- assoc )
    [ H{ } clone dup ] dip parse-toml [ update-toml ] each drop ;

: path>toml ( path -- assoc )
    utf8 file-contents toml> ;
