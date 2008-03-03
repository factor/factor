! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays io kernel memoize namespaces peg
peg.ebnf sequences strings html.elements xml.entities
xmode.code2html splitting io.streams.string html peg.parsers
html.elements sequences.deep unicode.categories ;
USE: tools.walker
IN: farkup

: delimiters ( -- string )
    "*_^~%[-=|\\\n" ; inline

MEMO: text ( -- parser )
    [ delimiters member? not ] satisfy repeat1
    [ >string escape-string ] action ;

MEMO: delimiter ( -- parser )
    [ dup delimiters member? swap "\n=" member? not and ] satisfy
    [ 1string ] action ;

: surround-with-foo ( string tag -- seq )
    dup <foo> swap </foo> swapd 3array ;

: delimited ( str html -- parser )
    [
        over token hide ,
        text [ surround-with-foo ] swapd curry action ,
        token hide ,
    ] seq* ;

MEMO: escaped-char ( -- parser )
    [ "\\" token hide , any-char , ] seq* [ >string ] action ;

MEMO: strong ( -- parser ) "*" "strong" delimited ;
MEMO: emphasis ( -- parser ) "_" "em" delimited ;
MEMO: superscript ( -- parser ) "^" "sup" delimited ;
MEMO: subscript ( -- parser ) "~" "sub" delimited ;
MEMO: inline-code ( -- parser ) "%" "code" delimited ;
MEMO: nl ( -- parser ) "\n" token ;
MEMO: 2nl ( -- parser ) "\n\n" token hide ;
MEMO: h1 ( -- parser ) "=" "h1" delimited ;
MEMO: h2 ( -- parser ) "==" "h2" delimited ;
MEMO: h3 ( -- parser ) "===" "h3" delimited ;
MEMO: h4 ( -- parser ) "====" "h4" delimited ;

: render-code ( string mode -- string' )
    >r string-lines r>
    [ [ htmlize-lines ] with-html-stream ] with-string-writer ;

: make-link ( href text -- seq )
    >r escape-quoted-string r> escape-string
    [ "<a href=\"" , >r , r> "\">" , [ , ] when* "</a>" , ] { } make ;

MEMO: simple-link ( -- parser )
    [
        "[[" token hide ,
        [ "|]" member? not ] satisfy repeat1 ,
        "]]" token hide ,
    ] seq* [ first f make-link ] action ;

MEMO: labelled-link ( -- parser )
    [
        "[[" token hide ,
        [ CHAR: | = not ] satisfy repeat1 ,
        "|" token hide ,
        [ CHAR: ] = not ] satisfy repeat1 ,
        "]]" token hide ,
    ] seq* [ first2 make-link ] action ;

MEMO: link ( -- parser ) [ simple-link , labelled-link , ] choice* ;

DEFER: line
MEMO: list-item ( -- parser )
    [
        "-" token hide , line ,
    ] seq* [ "li" surround-with-foo ] action ;

MEMO: list ( -- parser )
    list-item "\n" token hide list-of
    [ "ul" surround-with-foo ] action ;

MEMO: table-column ( -- parser )
    text [ "td" surround-with-foo ] action ;

MEMO: table-row ( -- parser )
    [
        table-column "|" token hide list-of-many ,
    ] seq* [ "tr" surround-with-foo ] action ;

MEMO: table ( -- parser )
    table-row repeat1 [ "table" surround-with-foo ] action ;

MEMO: code ( -- parser )
    [
        "[" token hide ,
        [ "{" member? not ] satisfy repeat1 optional [ >string ] action ,
        "{" token hide ,
        [
            [ any-char , "}]" token ensure-not , ] seq*
            repeat1 [ concat >string ] action ,
            [ any-char , "}]" token hide , ] seq* optional [ >string ] action ,
        ] seq* [ concat ] action ,
    ] seq* [ first2 swap render-code ] action ;

MEMO: line ( -- parser )
    [
        text , strong , emphasis , link ,
        superscript , subscript , inline-code ,
        escaped-char , delimiter ,
    ] choice* repeat1 ;

MEMO: paragraph ( -- parser )
    line
    "\n" token over 2seq repeat0
    "\n" token "\n" token ensure-not 2seq optional 3seq
    [
        dup [ dup string? not swap [ blank? ] all? or ] deep-all?
        [ "<p>" swap "</p>" 3array ] unless
    ] action ;

MEMO: farkup ( -- parser )
    [
        list , table , h1 , h2 , h3 , h4 , code , paragraph , 2nl , nl ,
    ] choice* repeat0 "\n" token optional 2seq ;

: farkup. ( parse-result  -- )
    parse-result-ast
    [ dup string? [ write ] [ drop ] if ] deep-each ;

: parse-farkup ( string -- string' )
    farkup parse [ farkup. ] with-string-writer ;

! MEMO: table-column ( -- parser )
    ! text [ "td" surround-with-foo ] action ;
! 
! MEMO: table-row ( -- parser )
    ! [
        ! "|" token hide ,
        ! table-column "|" token hide list-of ,
        ! "|" token "\n" token 2array choice hide ,
    ! ] seq* [ "tr" surround-with-foo ] action ;
! 
! MEMO: table ( -- parser )
    ! table-row repeat1
    ! [ "table" surround-with-foo ] action ;
