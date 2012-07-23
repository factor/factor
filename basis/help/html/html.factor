! Copyright (C) 2008, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings.utf8 io.encodings.binary io.files
io.files.temp io.directories html.streams help help.home kernel
assocs sequences make words accessors arrays help.topics vocabs
vocabs.hierarchy help.vocabs namespaces prettyprint io
vocabs.loader serialize fry memoize unicode.case math.order
sorting debugger html xml.syntax xml.writer math.parser
sets hashtables ;
FROM: io.encodings.ascii => ascii ;
FROM: ascii => ascii? ;
IN: help.html

: escape-char ( ch -- )
    dup ascii? [
        dup H{
            { CHAR: " "__quo__" }
            { CHAR: * "__star__" }
            { CHAR: : "__colon__" }
            { CHAR: < "__lt__" }
            { CHAR: > "__gt__" }
            { CHAR: ? "__que__" }
            { CHAR: \\ "__back__" }
            { CHAR: | "__pipe__" }
            { CHAR: / "__slash__" }
            { CHAR: , "__comma__" }
            { CHAR: @ "__at__" }
            { CHAR: # "__hash__" }
            { CHAR: % "__percent__" }
        } at [ % ] [ , ] ?if
    ] [ number>string "__" "__" surround % ] if ;

: escape-filename ( string -- filename )
    [ [ escape-char ] each ] "" make ;

GENERIC: topic>filename* ( topic -- name prefix )

M: word topic>filename*
    dup vocabulary>> [
        [ name>> ] [ vocabulary>> ] bi 2array "word"
    ] [ drop f f ] if ;

M: link topic>filename* name>> dup [ "article" ] [ topic>filename* ] if ;
M: word-link topic>filename* name>> topic>filename* ;
M: vocab-spec topic>filename* vocab-name "vocab" ;
M: vocab-tag topic>filename* name>> "tag" ;
M: vocab-author topic>filename* name>> "author" ;
M: f topic>filename* drop \ f topic>filename* ;

: topic>filename ( topic -- filename )
    topic>filename* dup [
        [
            % "-" %
            dup array?
            [ [ escape-filename ] map "," join ]
            [ escape-filename ]
            if % ".html" %
        ] "" make
    ] [ 2drop f ] if ;

M: topic url-of topic>filename ;

M: pathname url-of
    string>> "resource:" ?head [
        "https://github.com/slavapestov/factor/blob/master/"
        prepend
    ] [ drop f ] if ;

: help-stylesheet ( -- xml )
    "vocab:help/html/stylesheet.css" ascii file-contents
    [XML <style><-></style> XML] ;

: help-navbar ( -- xml )
    "conventions" >link topic>filename
    [XML
        <div class="navbar">
        <b> Factor Documentation </b> |
        <a href="/">Home</a> |
        <a href=<->>Glossary</a> |
        <form method="get" action="/search" style="display:inline;">
            <input name="search" type="text"/>
            <button type="submit">Search</button>
        </form>
        <a href="http://factorcode.org" style="float:right; padding: 4px;">factorcode.org</a>
        </div>
     XML] ;

: help>html ( topic -- xml )
    [ article-title " - Factor Documentation" append ]
    [ drop help-stylesheet ]
    [
        [ help-navbar ]
        [ [ print-topic ] with-html-writer ]
        bi* append
    ] tri
    simple-page ;

: generate-help-file ( topic -- )
    dup topic>filename utf8 [ help>html write-xml ] with-file-writer ;

: all-vocabs-really ( -- seq )
    all-vocabs-recursive >hashtable no-roots remove-redundant-prefixes
    [ vocab-name "scratchpad" = not ] filter ;

: all-topics ( -- topics )
    [
        articles get keys [ >link ] map %
        all-words [ >link ] map %
        all-authors [ <vocab-author> ] map %
        all-tags [ <vocab-tag> ] map %
        all-vocabs-really %
    ] { } make ;

: serialize-index ( index file -- )
    [ [ [ topic>filename ] dip ] { } assoc-map-as object>bytes ] dip
    binary set-file-contents ;

: generate-indices ( -- )
    articles get keys [ [ >link ] [ article-title ] bi ] { } map>assoc "articles.idx" serialize-index
    all-words [ dup name>> ] { } map>assoc "words.idx" serialize-index
    all-vocabs-really [ dup vocab-name ] { } map>assoc "vocabs.idx" serialize-index ;

: (generate-help-files) ( -- )
    all-topics [ '[ _ generate-help-file ] try ] each ;

: generate-help-files ( -- )
    H{
        { recent-searches f }
        { recent-words f }
        { recent-articles f }
        { recent-vocabs f }
    } [ (generate-help-files) ] with-variables ;

: generate-help ( -- )
    "docs" cache-file
    [ make-directories ]
    [
        [
            generate-indices
            generate-help-files
        ] with-directory
    ] bi ;

MEMO: load-index ( name -- index )
    binary file-contents bytes>object ;

TUPLE: result title href ;

: partition-exact ( string results -- results' )
    [ title>> = ] with partition append ;

: offline-apropos ( string index -- results )
    load-index over >lower
    '[ [ drop _ ] dip >lower subseq? ] assoc-filter
    [ swap result boa ] { } assoc>map
    [ title>> ] sort-with
    partition-exact ;

: article-apropos ( string -- results )
    "articles.idx" offline-apropos ;

: word-apropos ( string -- results )
    "words.idx" offline-apropos ;

: vocab-apropos ( string -- results )
    "vocabs.idx" offline-apropos ;
