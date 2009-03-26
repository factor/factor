! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry help.markup help.topics io
kernel make math math.parser namespaces sequences sorting
summary tools.completion tools.vocabs help.vocabs
vocabs words unicode.case help ;
IN: help.apropos

: $completions ( seq -- )
    dup [ word? ] all? [ words-table ] [
        dup [ vocab-spec? ] all? [
            $vocabs
        ] [
            [ <$pretty-link> 1array ] map $table
        ] if
    ] if ;

TUPLE: more-completions seq ;

CONSTANT: max-completions 5

M: more-completions article-title
    seq>> length number>string " results" append ;

M: more-completions article-name
    seq>> length max-completions - number>string " more results" append ;

M: more-completions article-content
    seq>> sort-values keys \ $completions prefix ;

: (apropos) ( str candidates title -- element )
    [
        [ completions ] dip '[
            _ 1array \ $heading prefix ,
            [ max-completions short head keys \ $completions prefix , ]
            [ dup length max-completions > [ more-completions boa <$link> , ] [ drop ] if ]
            bi
        ] unless-empty
    ] { } make ;

: word-candidates ( words -- candidates )
    [ dup name>> >lower ] { } map>assoc ;

: vocab-candidates ( -- candidates )
    all-vocabs-seq [ dup vocab-name >lower ] { } map>assoc ;

: help-candidates ( seq -- candidates )
    [ [ >link ] [ article-title >lower ] bi ] { } map>assoc
    sort-values ;

: $apropos ( str -- )
    first
    [ all-words word-candidates "Words" (apropos) ]
    [ vocab-candidates "Vocabularies" (apropos) ]
    [ articles get keys help-candidates "Help articles" (apropos) ]
    tri 3array print-element ;

TUPLE: apropos search ;

C: <apropos> apropos

M: apropos article-title
    search>> "Search results for “" "”" surround ;

M: apropos article-name article-title ;

M: apropos article-content
    search>> 1array \ $apropos prefix ;

M: apropos >link ;

INSTANCE: apropos topic

: apropos ( str -- )
    <apropos> print-topic ;
