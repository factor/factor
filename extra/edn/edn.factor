! Copyright (C) 2025 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs combinators hash-sets hashtables
kernel make math math.parser peg peg.parsers sequences sets
splitting strings strings.parser unicode vectors words ;

IN: edn

TUPLE: keyword name ;

TUPLE: symbol name ;

TUPLE: tagged name value ;

<PRIVATE

: spaces ( -- parser )
    [ blank? ] satisfy repeat1 ;

: newline ( -- parser )
    "\n" token "\r\n" token 2choice ;

: comments ( -- parser )
    ";" token [ CHAR: \n = not ] satisfy repeat0 newline optional 3seq ;

: spaces-or-comments ( -- parser )
    spaces comments 2choice repeat1 ;

: nil-parser ( -- parser )
    "nil" token [ drop null ] action ;

: boolean-parser ( -- parser )
    "true" token [ drop t ] action
    "false" token [ drop f ] action
    2choice ;

: escaped ( -- parser )
    "\\" token hide [ "\"\\befnrt" member-eq? ] satisfy 2seq
    [ first escape ] action ;

: string-parser ( -- parser )
    escaped [ CHAR: \" = not ] satisfy 2choice repeat0
    "\"" dup surrounded-by [ >string ] action ;

: char-parser ( -- parser )
    "\\" token hide [ blank? not ] satisfy repeat1 [
        >string {
            { "newline" [ CHAR: \n ] }
            { "return" [ CHAR: \r ] }
            { "space" [ CHAR: \s ] }
            { "tab" [ CHAR: \t ] }
            [ "u" ?head [ hex> ] [ first ] if ]
        } case
    ] action 2seq [ first ] action ;

: keyword-parser ( -- parser )
    ":" token hide
    [ blank? not ] satisfy repeat1 [ >string ] action
    2seq [ first keyword boa ] action ;

: symbol-parser ( -- parser )
    [ [ digit? not ] [ [ alpha? ] [ ".*+!-_?$%&=<>" member? ] bi or ] bi and ] satisfy
    [ [ alpha? ] [ ".*+!-_?$%&=<>" member? ] bi or ] satisfy repeat0 2seq
    [ first2 swap prefix >string ] action
    "/" token list-of [ "/" join symbol boa ] action ;

: sign ( -- parser )
    "+" token "-" token 2choice ;

: decdigit ( -- parser )
    CHAR: 0 CHAR: 9 range ;

: int-parser ( -- parser )
    sign optional decdigit repeat1 "N" token hide optional 3seq
    [ "" concat-as string>number ] action ;

: exponent ( -- parser )
    "e" token "E" token 2choice sign optional
    decdigit repeat1 3seq [ "" concat-as ] action ;

: float-parser ( -- parser )
    [ sign optional , decdigit repeat1 , exponent , ] seq*
    [ sign optional , decdigit repeat1 , "." token , decdigit repeat1 , exponent optional , ] seq*
    2choice [ "" concat-as string>number ] action ;

DEFER: value-parser

: discard-parser ( -- parser )
    "#_" token spaces-or-comments optional value-parser 3seq ;

: ?value-parser ( -- parser )
    discard-parser hide comments hide value-parser 3choice ;

: values-parser ( -- parser )
    [
        spaces-or-comments optional hide ,
        ?value-parser ,
        spaces-or-comments hide ?value-parser 2seq repeat0
        [ concat ] action ,
        spaces-or-comments optional hide ,
    ] seq* [ dup length 1 > [ first2 swap prefix ] [ ?first ] if ] action ;

: list-parser ( -- parser )
    [
        "(" token hide , spaces-or-comments optional hide ,
        values-parser optional ,
        spaces-or-comments optional hide , ")" token hide ,
    ] seq* [ ?first >array ] action ;

: vector-parser ( -- parser )
    [
        "[" token hide , spaces-or-comments optional hide ,
        values-parser optional ,
        spaces-or-comments optional hide , "]" token hide ,
    ] seq* [ ?first >vector ] action ;

: pair-parser ( -- parser )
    value-parser spaces-or-comments hide value-parser 3seq ;

: pairs-parser ( -- parser )
    pair-parser
    [ [ CHAR: , = ] [ blank? ] bi or ] satisfy repeat1 hide
    pair-parser 2seq
    [ first ] action repeat0 2seq
    [ first2 swap prefix ] action ;

: map-parser ( -- parser )
    [
        "{" token hide , spaces-or-comments optional hide ,
        pairs-parser optional ,
        spaces-or-comments optional hide , "}" token hide ,
    ] seq* [ ?first >hashtable ] action ;

: set-parser ( -- parser )
    [
        "#{" token hide , spaces-or-comments optional hide ,
        values-parser optional ,
        spaces-or-comments optional hide , "}" token hide ,
    ] seq* [ ?first >hash-set ] action ;

: tagged-parser ( -- parser )
    [
        "#" token hide ,
        [ blank? not ] satisfy repeat1 [ >string ] action ,
        spaces-or-comments hide ,
        value-parser ,
    ] seq* [ first2 tagged boa ] action ;

: value-parser ( -- parser )
    [
        [
            nil-parser ,
            boolean-parser ,
            string-parser ,
            keyword-parser ,
            symbol-parser ,
            string-parser ,
            char-parser ,
            float-parser ,
            int-parser ,
            list-parser ,
            vector-parser ,
            map-parser ,
            set-parser ,
            tagged-parser ,
        ] choice*
    ] delay ;

! XXX: #inst "rfc-3339-format"
! XXX: #uuid "f81d4fae-7dec-11d0-a765-00a0c91e6bf6"

PRIVATE>

: edn> ( string -- object )
    values-parser parse-fully ;

GENERIC: >edn ( object -- string )

M: word >edn dup null eq? [ drop "null" ] [ call-next-method ] if ;
M: t >edn drop "true" ;
M: f >edn drop "false" ;
M: integer >edn number>string ;
M: number >edn >float number>string ;
M: string >edn "\"" dup surround ;
M: assoc >edn [ [ >edn ] bi@ " " glue ] { } assoc>map ", " join "{" "}" surround ;
M: set >edn members [ >edn ] map " " join "#{" "}" surround ;
M: sequence >edn [ >edn ] map " " join "(" ")" surround ;
M: keyword >edn name>> ":" prepend ;
M: symbol >edn name>> ;
M: tagged >edn [ name>> ] [ value>> >edn ] bi " " glue ;
