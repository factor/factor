! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry help.markup help.topics io
kernel make math math.parser namespaces sequences sorting
summary tools.completion vocabs.hierarchy help.vocabs
vocabs words unicode help combinators locals ;
IN: help.apropos

: $completions ( seq -- )
    dup [ word? ] all? [ words-table ] [
        dup [ vocab-spec? ] all? [
            $vocabs
        ] [
            [ <$pretty-link> 1array ] map $table
        ] if
    ] if ;

SYMBOLS: word-result vocabulary-result article-result ;

: category>title ( category -- name )
    {
        { word-result [ "Words" ] }
        { vocabulary-result [ "Vocabularies" ] }
        { article-result [ "Help articles" ] }
    } case ;

: category>name ( category -- name )
    {
        { word-result [ "word" ] }
        { vocabulary-result [ "vocabulary" ] }
        { article-result [ "help article" ] }
    } case ;

TUPLE: more-completions seq search category ;

CONSTANT: max-completions 5

M: more-completions valid-article? drop t ;

M: more-completions article-title
    [
        "All " %
        [ seq>> length # " " % ]
        [ category>> category>name % ]
        [ " results for \"" % search>> % "\"" % ] tri
    ] "" make ;

M: more-completions article-content
    seq>> [ second >lower ] sort-by keys \ $completions prefix ;

:: (apropos) ( search completions category -- element )
    completions [
        [
            { $heading search } ,
            [ max-completions index-or-length head keys \ $completions prefix , ]
            [
                length max-completions >
                [ { $link T{ more-completions f completions search category } } , ] when
            ] bi
        ] unless-empty
    ] { } make ;

: articles-matching ( str -- seq )
    articles get
    [ [ >link ] [ title>> ] bi* ] { } assoc-map-as
    completions ;

: $apropos ( str -- )
    first
    [ dup words-matching word-result (apropos) ]
    [ dup vocabs-matching vocabulary-result (apropos) ]
    [ dup articles-matching article-result (apropos) ]
    tri 3array print-element ;

TUPLE: apropos-search text ;

C: <apropos-search> apropos-search

M: apropos-search valid-article? drop t ;

M: apropos-search article-title
    text>> "Search results for \"" "\"" surround ;

M: apropos-search article-content
    text>> 1array \ $apropos prefix ;

M: apropos-search >link ;

INSTANCE: apropos-search topic

: apropos ( str -- )
    [ unicode:blank? ] trim <apropos-search> print-topic ;
