! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays io kernel memoize namespaces peg
peg.ebnf sequences strings html.elements xml.entities
xmode.code2html splitting io.streams.string html
html.elements sequences.deep ascii ;
! unicode.categories ;
USE: tools.walker
IN: farkup

MEMO: any-char ( -- parser ) [ drop t ] satisfy ;

: delimiters ( -- string )
    "*_^~%=[-|\\\n" ; inline

MEMO: text ( -- parser )
    [ delimiters member? not ] satisfy repeat1
    [ >string escape-string ] action ;

MEMO: delimiter ( -- parser )
    [ dup delimiters member? swap CHAR: \n = not and ] satisfy
    [ 1string ] action ;

: delimited ( str html -- parser )
    [
        over token hide ,
        text [ dup <foo> swap </foo> swapd 3array ] swapd curry action ,
        token hide ,
    ] seq* ;

MEMO: escaped-char ( -- parser )
    [ "\\" token hide , any-char , ] seq* [ >string ] action ;

MEMO: strong ( -- parser ) "*" "strong" delimited ;
MEMO: emphasis ( -- parser ) "_" "em" delimited ;
MEMO: superscript ( -- parser ) "^" "sup" delimited ;
MEMO: subscript ( -- parser ) "~" "sub" delimited ;
MEMO: inline-code ( -- parser ) "%" "code" delimited ;
MEMO: h1 ( -- parser ) "=" "h1" delimited ;
MEMO: h2 ( -- parser ) "==" "h2" delimited ;
MEMO: h3 ( -- parser ) "===" "h3" delimited ;
MEMO: h4 ( -- parser ) "====" "h4" delimited ;
MEMO: 2nl ( -- parser ) "\n\n" token hide ;

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
        "-" token hide ,
        line ,
    ] seq*
    [ "li" <foo> swap "li" </foo> 3array ] action ;

MEMO: list ( -- parser )
    list-item "\n" token hide list-of
    [ "ul" <foo> swap "ul" </foo> 3array ] action ;

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

MEMO: table-column ( -- parser ) [ "|" token text ] seq* ;
MEMO: table-row ( -- parser ) [ ] seq* ; 
MEMO: table ( -- parser ) [ "[" ] seq* ;

MEMO: line ( -- parser )
    [
        text , strong , emphasis , link ,
        superscript , subscript , inline-code ,
        escaped-char , delimiter ,
    ] choice* repeat1 ;

MEMO: paragraph ( -- parser )
    [
        line ,
        "\n" token ,
    ] choice* repeat1 [
        dup [ dup string? not swap [ blank? ] all? or ] deep-all?
        [ "<p>" swap "</p>" 3array ] unless
    ] action ;

MEMO: farkup ( -- parser )
    [
        list , h1 , h2 , h3 , h4 , code , paragraph , 2nl ,
    ] choice* repeat1 ;

: parse-farkup ( string -- string' )
    farkup parse parse-result-ast
    [ [ dup string? [ write ] [ drop ] if ] deep-each ] with-string-writer ;
