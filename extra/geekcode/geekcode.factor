! Copyright (C) 2015 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs combinators.short-circuit
grouping hashtables html.parser html.parser.analyzer
html.parser.printer http.client io io.styles kernel memoize
sequences splitting unicode.categories wrap.strings ;
FROM: sequences => change-nth ;

IN: geekcode

<PRIVATE

: split-text ( str -- seq )
    [ blank? ] split-when harvest ;

: parse-section-attr ( seq -- section )
    [ name>> "dt" = ] split-when [
        [ name>> "dd" = ] split-when
        [ html-text split-text " " join ] map harvest
    ] map harvest ;

: parse-section-attrs ( seq -- specs )
    [ name>> "dl" = ] find-between-all 2 tail 2 head*
    [ parse-section-attr ] map 0 over [
        first [ " " split1 " " split1 nip 2array ] map
    ] change-nth [ >hashtable ] map ;

: parse-section-names ( seq -- names )
    [
        { [ name>> "hr" = ] [ "size" attribute not ] } 1&&
    ] split-when 4 tail [
        "h2" find-between-first first text>>
    ] map "Type" prefix ;

: parse-spec ( seq -- spec )
    [ parse-section-names ] [ parse-section-attrs ] bi zip ;

MEMO: geekcode-spec ( -- obj )
    "http://www.geekcode.com/geek.html" http-get nip
    parse-html parse-spec ;

: lookup-code ( code -- result/f )
    geekcode-spec [ second at ] with map-find
    [ first swap 2array ] [ drop f ] if* ;

PRIVATE>

: geekcode ( geekcode -- str )
    split-text [ lookup-code ] map harvest ;

: geekcode. ( geekcode -- )
    geekcode standard-table-style [
        [
            [
                [ [ write ] with-cell ]
                [ [ 60 wrap-string write ] with-cell ] bi*
            ] with-row
        ] assoc-each
    ] tabular-output nl ;
