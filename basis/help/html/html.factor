! Copyright (C) 2008, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit
debugger fry help help.home help.topics help.vocabs html
html.streams io.directories io.encodings.binary
io.encodings.utf8 io.files io.files.temp io.pathnames kernel
locals make math math.parser memoize namespaces sequences
serialize sorting splitting tools.completion vocabs
vocabs.hierarchy words xml.data xml.syntax xml.traversal
xml.writer ;
FROM: io.encodings.ascii => ascii ;
FROM: ascii => ascii? ;
IN: help.html

: escape-char ( ch -- )
    dup ascii? [
        dup H{
            { CHAR: \" "__quo__" }
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
    topic>filename* [
        [
            % "-" %
            dup array?
            [ [ escape-filename ] map "," join ]
            [ escape-filename ]
            if % ".html" %
        ] "" make
    ] [ drop f ] if* ;

M: topic url-of topic>filename ;

M: pathname url-of
    string>> "resource:" ?head [
        "https://github.com/factor/factor/blob/master/"
        prepend
    ] [ drop f ] if ;

: help-stylesheet ( stylesheet -- xml )
    "vocab:help/html/stylesheet.css" ascii file-contents
    swap "\n" glue [XML <style><-></style> XML] ;

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

: bijective-base26 ( n -- name )
    [ dup 0 > ] [ 1 - 26 /mod CHAR: a + ] "" produce-as nip reverse! ;

: css-class ( style classes -- name )
    dup '[ drop _ assoc-size 1 + bijective-base26 ] cache ;

: css-classes ( classes -- stylesheet )
    [
        [ " { " "}" surround ] [ "." prepend ] bi* prepend
    ] { } assoc>map "\n" join ;

:: css-styles-to-classes ( body -- stylesheet body )
    H{ } clone :> classes
    body [
        dup xml-chunk? [
            seq>> [ tag? ] filter
            "span" "div" [ deep-tags-named ] bi-curry@ bi append
            [
                dup {
                    [ "style" attr ]
                    [ "class" attr not ]
                } 1&& [
                    attrs>> [ V{ } like ] change-alist
                    "style" over delete-at* drop classes css-class
                    "class" rot set-at
                ] [ drop ] if
            ] each
        ] [ drop ] if
    ] each classes sort-values css-classes body ;

: help>html ( topic -- xml )
    [ article-title " - Factor Documentation" append ]
    [
        [ print-topic ] with-html-writer css-styles-to-classes
        [ help-stylesheet ] [ help-navbar prepend ] bi*
    ] bi simple-page ;

: generate-help-file ( topic -- )
    dup topic>filename utf8 [ help>html write-xml ] with-file-writer ;

: all-vocabs-really ( -- seq )
    all-disk-vocabs-recursive filter-vocabs
    [ vocab-name "scratchpad" = ] reject ;

: all-topics ( -- topics )
    [
        articles get keys [ >link ] map %
        all-words [ >link ] map %
        all-authors [ <vocab-author> ] map %
        all-tags [ <vocab-tag> ] map %
        all-vocabs-really %
    ] { } make ;

: serialize-index ( index file -- )
    binary [
        [ [ topic>filename ] dip ] { } assoc-map-as serialize
    ] with-file-writer ;

: generate-article-index ( -- )
    articles get [ [ >link ] [ article-title ] bi* ] assoc-map
    "articles.idx" serialize-index ;

: generate-word-index ( -- )
    all-words [ dup name>> ] { } map>assoc
    "words.idx" serialize-index ;

: generate-vocab-index ( -- )
    all-vocabs-really [ dup vocab-name ] { } map>assoc
    "vocabs.idx" serialize-index ;

: generate-indices ( -- )
    generate-article-index
    generate-word-index
    generate-vocab-index ;

: generate-help-files ( -- )
    H{
        { recent-searches f }
        { recent-words f }
        { recent-articles f }
        { recent-vocabs f }
    } [
        all-topics [ '[ _ generate-help-file ] try ] each
    ] with-variables ;

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

: offline-apropos ( string index -- results )
    load-index completions ;

: article-apropos ( string -- results )
    "articles.idx" offline-apropos ;

: word-apropos ( string -- results )
    "words.idx" offline-apropos ;

: vocab-apropos ( string -- results )
    "vocabs.idx" offline-apropos ;
