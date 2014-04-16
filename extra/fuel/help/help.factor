! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs combinators fuel.eval help help.crossref
help.markup help.topics io io.streams.string kernel make namespaces
parser prettyprint sequences summary help.vocabs
vocabs vocabs.loader vocabs.hierarchy vocabs.metadata vocabs.parser words see
listener sets ;
FROM: vocabs.hierarchy => child-vocabs ;
IN: fuel.help

<PRIVATE

: fuel-value-str ( word -- str )
    [ pprint-short ] with-string-writer ; inline

: fuel-definition-str ( word -- str )
    [ see ] with-string-writer ; inline

: fuel-methods-str ( word -- str )
    methods [ f ] [
        [ [ see nl ] each ] with-string-writer
    ] if-empty ; inline

: fuel-related-words ( word -- seq )
    dup "related" word-prop remove ; inline

: fuel-parent-topics ( word -- seq )
    help-path [ dup article-title swap 2array ] map ; inline

SYMBOL: $doc-path

: (fuel-word-element) ( word -- element )
    \ article swap dup article-title swap
    [
        {
            [ fuel-parent-topics [ \ $doc-path prefix , ] unless-empty ]
            [ \ $vocabulary swap vocabulary>> 2array , ]
            [ word-help % ]
            [ fuel-related-words [ \ $related swap 2array , ] unless-empty ]
            [ get-global [ \ $value swap fuel-value-str 2array , ] when* ]
            [ \ $definition swap fuel-definition-str 2array , ]
            [ fuel-methods-str [ \ $methods swap 2array , ] when* ]
        } cleave
    ] { } make 3array ;

: fuel-vocab-help-row ( vocab -- element )
    [ vocab-name ] [ summary ] bi 2array ;

: fuel-vocab-help-root-heading ( root -- element )
    [ "Children from " prepend ] [ "Other children" ] if* \ $heading swap 2array ;

SYMBOL: vocab-list
SYMBOL: describe-words

: fuel-vocab-help-table ( vocabs -- element )
    [ fuel-vocab-help-row ] map vocab-list prefix ;

: fuel-vocab-list ( assoc -- seq )
    [
        [ drop f ] [
            [ fuel-vocab-help-root-heading ]
            [ fuel-vocab-help-table ] bi*
            [ 2array ] [ drop f ] if*
        ] if-empty
    ] { } assoc>map sift ;

: fuel-vocab-children-help ( name -- element )
    child-vocabs fuel-vocab-list ; inline

: fuel-vocab-describe-words ( name -- element )
    [ words. ] with-string-writer \ describe-words swap 2array ; inline

: (fuel-vocab-element) ( name -- element )
    dup require \ article swap dup >vocab-link
    [
        {
            [ vocab-authors [ \ $authors prefix , ] when* ]
            [ vocab-tags [ \ $tags prefix , ] when* ]
            [ summary [ { $heading "Summary" } swap 2array , ] when* ]
            [ drop \ $nl , ]
            [ vocab-help [ lookup-article content>> % ] when* ]
            [ name>> fuel-vocab-describe-words , ]
            [ name>> fuel-vocab-children-help % ]
        } cleave
    ] { } make 3array ;

PRIVATE>

: (fuel-word-help) ( name -- elem )
    search [ [ auto-use? on (fuel-word-element) ] with-scope ] [ f ] if* ;

: (fuel-word-synopsis) ( word usings -- str/f )
    [
        [ lookup-vocab ] filter interactive-vocabs [ append ] change
        search [ synopsis ] [ f ] if*
    ] with-scope ;

: (fuel-word-def) ( name -- str )
    search [ [ def>> pprint ] with-string-writer ] [ f ] if* ; inline

: (fuel-vocab-summary) ( name -- str ) >vocab-link summary ; inline

: (fuel-vocab-help) ( name -- str )
    dup empty? [ fuel-vocab-children-help ] [ (fuel-vocab-element) ] if ;

: (fuel-get-vocabs/author) ( author -- element )
    [ "Vocabularies by " prepend \ $heading swap 2array ]
    [ authored fuel-vocab-list ] bi 2array ;

: (fuel-get-vocabs/tag) ( tag -- element )
    [ "Vocabularies tagged " prepend \ $heading swap 2array ]
    [ tagged fuel-vocab-list ] bi 2array ;

: format-index ( seq -- seq )
    [ [ >link name>> ] [ article-title ] bi 2array \ $subsection prefix ] map ;
