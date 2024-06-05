! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: arrays combinators combinators.short-circuit help
help.apropos help.markup help.stylesheet help.topics io
io.styles kernel math namespaces sequences sorting splitting
strings unicode words ;

IN: help.search

<PRIVATE

: search-words ( str -- seq )
    >lower "-" split [ [ blank? ] split-when ] map concat ;

: element-value ( element -- str )
    dup array? [
        dup ?first {
            { \ $link [ second article-name ] }
            { \ $vocab-link [ second ] }
            { \ $emphasis [ second ] }
            { \ $subsection [ second article-name ] }
            { \ $subsections [ rest [ article-name ] map join-words ] }
            { \ $description [ rest [ element-value ] map join-words ] }
            { \ $notes [ rest [ element-value ] map join-words ] }
            { \ $snippet [ rest [ element-value ] map join-words ] }
            [ 2drop f ]
        } case
    ] [ [ string? ] ?and ] if ;

MEMO: article-words ( name -- words )
    article-content [ element-value ] map join-words search-words
    [ [ digit? ] all? ] reject
    [ [ { [ letter? ] [ digit? ] } 1|| not ] trim ] map! harvest  ;

: (search-articles) ( string -- seq' )
    search-words [ { } ] [
        [ all-articles ] dip
        dup length 1 > [
            '[ article-words _ subseq-of? ] filter
        ] [
            first '[ article-words [ _ head? ] any? ] filter
        ] if
    ] if-empty [ article-name ] sort-by ;

PRIVATE>

: search-articles ( string -- )
    [
        last-element off
        [
            "Search results for “" "”" surround
            title-style get [ format ] ($block)
        ]
        [
            (search-articles) [ word? ] partition swap
            "Articles" "Words"
            [ over empty? [ 2drop ] [ $heading $completions ] if ]
            bi-curry@ bi*
        ] bi
    ] with-default-style nl ;
