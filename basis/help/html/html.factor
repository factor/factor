! Copyright (C) 2008, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit
debugger formatting fry help help.home help.topics help.vocabs
html html.streams io.directories io.encodings.binary
io.encodings.utf8 io.files io.files.temp io.pathnames kernel
locals make math math.parser memoize namespaces regexp sequences
sequences.deep serialize sorting splitting system tools.completion
vocabs vocabs.hierarchy words xml.data xml.syntax xml.traversal
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

: help-meta ( -- xml )
    [XML <meta
            name="viewport"
            content="width=device-width, initial-scale=1"
            charset="utf-8"
        /> XML] ;

: help-navbar ( -- xml )
    "conventions" >link topic>filename
    [XML
        <div class="navbar">
            <div class="navrow">
                <a href="https://factorcode.org">
                <img src="favicon.ico" width="24" height="24" />
                </a>
                <a href="/">Handbook</a>
                <a href=<->>Glossary</a>
                <form method="get" action="/search" style="float: right;">
                    <input placeholder="Search" name="search" type="text"/>
                    <input type="submit" value="Go"/>
                </form>
            </div>
        </div>
     XML] ;

: help-footer ( -- xml )
    version-info "\n" split1 drop
    [XML
        <div class="footer">
        <p>
        This documentation was generated offline from a
        <code>load-all</code> image.  If you want, you can also
        browse the documentation from within the <a
        href="article-ui-tools.html">UI developer tools</a>. See
        the <a href="https://factorcode.org">Factor website</a>
        for more information.
        </p>
        <p><-></p>
        </div>
    XML] ;

: bijective-base26 ( n -- name )
    [ dup 0 > ] [ 1 - 26 /mod CHAR: a + ] "" produce-as nip reverse! ;

: css-class ( style classes -- name )
    dup '[ drop _ assoc-size 1 + bijective-base26 ] cache ;

: fix-css-style ( style -- style' )
    R/ font-size: \d+pt;/ [
        "font-size: " ?head drop "pt;" ?tail drop
        string>number 2 -
        "font-size: %dpt;" sprintf
    ] re-replace-with

    R/ padding: \d+px;/ [
        "padding: " ?head drop "px;" ?tail drop
        string>number dup even? [ 2 * 1 + ] [ 2 * ] if
        number>string "padding: " "px;" surround
    ] re-replace-with

    R/ width: \d+px;/ [
       drop ""
    ] re-replace-with

    R/ font-family: monospace;/ [
        " white-space: pre-wrap; line-height: 125%;" append
    ] re-replace-with ;

: fix-help-header ( classes -- classes )
    dup [
        [ ".a" head? ] [ "#f4efd9;" swap subseq? ] bi and
    ] find [
        "padding: 10px;" "padding: 0px;" replace
        "background-color: #f4efd9;" "background-color: white;" replace
        "}" ?tail drop
        " border-bottom: 1px dashed #ccc; width: 100%; padding-top: 15px; padding-bottom: 10px; }"
        append swap pick set-nth {
            ".a a { color: black; font-size: 24pt; }"
            ".a * a { color: #2A5DB0; font-size: 12pt; }"
            ".a td { border: none; }"
            ".a tr:hover { background-color: white; }"
        } prepend
    ] [ drop ] if* ;

: css-classes ( classes -- stylesheet )
    [
        [ fix-css-style " { " "}" surround ] [ "." prepend ] bi* prepend
    ] { } assoc>map fix-help-header join-lines ;

:: css-styles-to-classes ( body -- stylesheet body )
    H{ } clone :> classes
    body [
        dup xml-chunk? [
            seq>> [
                dup {
                    [ tag? ]
                    [ "style" attr ]
                    [ "class" attr not ]
                } 1&& [
                    [ clone [ V{ } like ] change-alist ] change-attrs
                    "style" over delete-at* drop classes css-class
                    "class" rot set-at
                ] [ drop ] if
            ] deep-each
        ] [ drop ] if
    ] each classes sort-values css-classes body ;

: retina-image ( path -- path' )
    "@2x" over subseq? [ "." split1-last "@2x." glue ] unless ;

: ?copy-file ( from to -- )
    dup file-exists? [ 2drop ] [ copy-file ] if ;

: cache-images ( body -- body' )
    dup [
        dup xml-chunk? [
            seq>> [
                T{ name { main "img" } } over tag-named? [
                    dup "src" attr
                    retina-image dup file-name
                    [ ?copy-file ] keep
                    "src" set-attr
                ] [ drop ] if
            ] deep-each
        ] [ drop ] if
    ] each ;

: help>html ( topic -- xml )
    [ article-title " - Factor Documentation" append ]
    [
        [ print-topic ] with-html-writer
        css-styles-to-classes cache-images
        "resource:extra/websites/factorcode/favicon.ico" dup file-name ?copy-file
        [ help-stylesheet help-meta prepend help-navbar ] dip help-footer
        [XML <-><div class="page"><-><-></div> XML]
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
