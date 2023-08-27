! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit help help.crossref help.markup
help.markup.private help.topics help.vocabs io io.streams.string
kernel make namespaces parser prettyprint see sequences
splitting summary vocabs vocabs.hierarchy vocabs.metadata
vocabs.parser words ;
IN: fuel.help

SYMBOLS: $doc-path $next-link $prev-link $fuel-nav-crumbs ;

: articles-crumbs ( seq -- crumbs )
    [ dup article-title \ article 3array ] map ;

: base-crumbs ( -- crumbs )
    { "handbook" "vocab-index" } [ dup article-title \ article 3array ] map ;

: vocab-own-crumbs ( vocab-name -- crumbs )
    "." split unclip [
        [ CHAR: . suffix ] dip append
    ] accumulate swap suffix
    [ dup "." split last \ vocab 3array ] map ;

: vocab-crumbs ( vocab-name -- crumbs )
    vocab-own-crumbs base-crumbs prepend ;

: article-parents ( article-name -- parents )
    [ article-parent ] follow
    dup last "handbook" = [ "handbook" suffix ] unless
    reverse but-last ;

: article-crumbs ( article-name -- crumbs )
    article-parents [ dup article-title \ article 3array ] map ;

<PRIVATE

: find-word ( name -- word/f )
    { [ search ] [ words-named ?first ] } 1|| ;

: definition-str ( word -- str )
    [ see ] with-string-writer ; inline

: methods-str ( word -- str )
    methods [ f ] [
        [ [ see nl ] each ] with-string-writer
    ] if-empty ; inline

: related-words ( word -- seq )
    dup "related" word-prop remove ; inline

: parent-topics ( word -- seq )
    help-path [ dup article-title swap 2array ] map ; inline

: next/prev-link ( link link-symbol -- 3arr )
    swap [ name>> ] [ [ link-long-text ] with-string-writer ] bi 3array ;

: word-element ( word -- element )
    \ article swap dup article-title swap
    [
        {
            [ vocabulary>> vocab-crumbs \ $fuel-nav-crumbs prefix , ]
            [
                >link
                [ prev-article [ \ $prev-link next/prev-link , ] when* ]
                [ next-article [ \ $next-link next/prev-link , ] when* ] bi
            ]
            [ parent-topics [ \ $doc-path prefix , ] unless-empty ]
            [ help:word-help % ]
            [ related-words [ \ $related swap 2array , ] unless-empty ]
            [ get-global [ \ $value swap unparse-short 2array , ] when* ]
            [ \ $definition swap definition-str 2array , ]
            [ methods-str [ \ $methods swap 2array , ] when* ]
        } cleave
    ] { } make 3array ;

: vocab-help-row ( vocab -- element )
    [ vocab-name ] [ summary ] bi 2array ;

: vocab-help-root-heading ( root -- element )
    [ "Children from " prepend ] [ "Other children" ] if* \ $heading swap 2array ;

SYMBOL: vocab-list
SYMBOL: describe-words

: vocab-help-table ( vocabs -- element )
    [ vocab-help-row ] map vocab-list prefix ;

: do-vocab-list ( assoc -- seq )
    [
        [ drop f ] [
            [ vocab-help-root-heading ]
            [ vocab-help-table ] bi*
            [ 2array ] [ drop f ] if*
        ] if-empty
    ] { } assoc>map sift ;

: vocab-children-help ( name -- element )
    disk-vocabs-for-prefix do-vocab-list ; inline

: vocab-describe-words ( name -- element )
    [ words. ] with-string-writer dup "\n" = [ drop f ] when
    \ describe-words swap 2array ; inline

: vocab-element ( name -- element )
    dup require \ article swap dup >vocab-link
    [
        {
            [ name>> vocab-crumbs but-last \ $fuel-nav-crumbs prefix , ]
            [ vocab-authors [ \ $authors prefix , ] when* ]
            [ vocab-tags [ \ $tags prefix , ] when* ]
            [ summary [ { $heading "Summary" } swap 2array , ] when* ]
            [ drop \ $nl , ]
            [ vocabs:vocab-help [ lookup-article content>> % ] when* ]
            [ name>> vocab-describe-words , ]
            [ name>> vocab-children-help % ]
        } cleave
    ] { } make 3array ;

PRIVATE>

: word-help ( name -- elem/f )
    find-word [
        [ auto-use? on word-element ] with-scope
    ] [ f ] if* ;

: word-synopsis ( name -- str/f )
    find-word [ synopsis ] [ f ] if* ;

: word-def ( name -- str )
    find-word [ [ def>> pprint ] with-string-writer ] [ f ] if* ; inline

: vocab-summary ( name -- str ) >vocab-link summary ; inline

: vocab-help ( name -- str )
    dup empty? [ vocab-children-help ] [ vocab-element ] if ;

: add-crumb ( crumbs article -- crumbs' )
    dup article-name 2array suffix ;

: simple-element ( title content crumbs -- element )
    \ $fuel-nav-crumbs prefix prefix \ article -rot 3array ;

: get-vocabs/author ( author -- element )
    [ "Vocabularies by " prepend ] [ authored do-vocab-list ] bi
    base-crumbs "vocab-authors" add-crumb simple-element ;

: get-vocabs/tag ( tag -- element )
    [ "Vocabularies tagged " prepend ] [ tagged do-vocab-list ] bi
    base-crumbs "vocab-tags" add-crumb simple-element ;

: format-index ( seq -- seq )
    [ [ >link name>> ] [ article-title ] bi 2array \ $subsection prefix ] map ;

: article-element ( name -- element )
    \ article swap dup lookup-article
    [ nip title>> ]
    [
        [ article-crumbs \ $fuel-nav-crumbs prefix ] [ content>> ] bi*
        \ $nl prefix swap prefix
    ] 2bi 3array ;

: vocab-help-article?  ( name -- ? )
    dup lookup-vocab [ help>> = ] [ drop f ] if* ;

: get-article ( name -- element )
    dup vocab-help-article? [ vocab-help ] [ article-element ] if ;
