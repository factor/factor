! Copyright (C) 2008, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs colors
combinators.short-circuit debugger formatting help help.home
help.topics help.vocabs html html.streams io.directories
io.encodings.ascii io.encodings.binary io.encodings.utf8
io.files io.files.temp io.pathnames kernel make math math.parser
namespaces regexp sequences sequences.deep serialize sets
sorting splitting strings system tools.completion vocabs
vocabs.hierarchy words xml.data xml.syntax xml.traversal
xml.writer ;
FROM: io.encodings.ascii => ascii ;
FROM: ascii => ascii? ;
IN: help.html

ERROR: not-printable ch ;

: check-printable ( ch -- ch )
    dup printable? [ not-printable ] unless ;

: escape-char ( ch -- )
    dup ascii? [
        [
            H{
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
            } at
        ] [ % ] [ check-printable , ] ?if
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
    [XML
        <meta
            name="viewport"
            content="width=device-width, initial-scale=1"
            charset="utf-8"
        />
        <meta
            name="theme-color"
            content="#f5f5f5"
            media="(prefers-color-scheme: light)"
        />
        <meta
            name="theme-color"
            content="#373e48"
            media="(prefers-color-scheme: dark)"
        />
    XML] ;

: help-script ( -- xml )
    [XML
        <script type="text/javascript">
        document.addEventListener('keydown', function (event) {
            if (event.code == 'Slash') {
                let input = document.getElementById('search');
                if (input != null) {
                    if (input !== document.activeElement) {
                        event.preventDefault();
                        setTimeout(function() {
                            input.focus();
                        }, 0);
                    }
                }
            }
        });
        </script>
    XML] ;

: help-header ( stylesheet -- xml )
    help-stylesheet help-meta swap help-script 3append ;

: help-nav ( -- xml )
    "conventions" >link topic>filename
    [XML
        <nav>
            <form method="get" action="/search" style="float: right;">
                <input placeholder="Search" id="search" name="search" type="text" tabindex="1" />
                <input type="submit" value="Go" tabindex="1" />
            </form>
            <a href="https://factorcode.org">
            <img src="favicon.ico" width="24" height="24" />
            </a>
            <a href="/">Handbook</a>
            <a href=<->>Glossary</a>
        </nav>
    XML] ;

: help-footer ( -- xml )
    vm-info "\n" split1 drop
    [XML
        <footer>
        <p>
        This documentation was generated offline from a
        <code>load-all</code> image.  If you want, you can also
        browse the documentation from within the <a
        href="article-ui-tools.html">UI developer tools</a>. See
        the <a href="https://factorcode.org">Factor website</a>
        for more information.
        </p>
        <p><-></p>
        </footer>
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
        string>number 2 * number>string
        "padding: " "px;" surround
    ] re-replace-with

    R/ width: \d+px;/ [
       drop ""
    ] re-replace-with

    R/ font-family: monospace;/ [
        " margin-top: 0.5em; margin-bottom: 0.5em; width: fit-content; white-space: pre-wrap; line-height: 125%;" append
    ] re-replace-with ;

: fix-help-header ( classes -- classes )
    dup [
        [ ".a" head? ] [ "#f4efd9;" subseq-of? ] bi and
    ] find [
        "padding: 10px;" "" replace
        "background-color: #f4efd9;" "" replace
        "}" ?tail drop
        " border-bottom: 1px dashed #d5d5d5; width: 100%; padding-top: 10px; padding-bottom: 10px; }"
        append swap pick set-nth {
            ".a a { color: black; font-size: 24pt; line-height: 100%; }"
            ".a * a { color: #2a5db0; font-size: 12pt; }"
            ".a td { border: none; }"
            ".a tr:hover { background-color: transparent }"
        } prepend
    ] [ drop ] if* ;

: dark-mode-css ( classes -- classes' )
    { "" "/* Dark mode */" "@media (prefers-color-scheme:dark) {" }
    swap [
        R/ {[^}]+}/ [
            "{" ?head drop "}" ?tail drop ";" split
            [ [ blank? ] trim ] map harvest [ ";" append ] map
            [ R/ (#[0-9a-fA-F]+|white|black);/ re-contains? ] filter
            [
                R/ (#[0-9a-fA-F]+|white|black);/ [
                    >string H{
                        { "#000000;" "#bdc1c6;" }
                        { "#2a5db0;" "#8ab4f8;" }
                        { "#333333;" "#d5d5d5;" }
                        { "#373e48;" "#ffffff;" }
                        { "#8b4500;" "orange;" }
                        { "#d5d5d5;" "#666;" }
                        { "#e3e2db;" "#444444;" }
                        { "white;" "#202124;" }
                        { "black;" "white;" }
                        { "transparent;" "transparent;" }
                    } ?at [
                        but-last parse-color inverse-color color>hex ";" append
                    ] unless
                ] re-replace-with
            ] map " " join "{ " " }" surround
        ] re-replace-with "    " prepend
        dup "{  }" subseq-of? [ drop f ] when
    ] map harvest append "}" suffix ;

: css-classes ( classes -- stylesheet )
    [
        [ fix-css-style " { " "}" surround ] [ "." prepend ] bi* prepend
    ] { } assoc>map fix-help-header dup dark-mode-css append join-lines ;

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
    dup "@2x" subseq-of? [ "." split1-last "@2x." glue ] unless ;

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
        [ help-header help-nav ] dip help-footer
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
    all-words [ dup name>> ] map>alist
    "words.idx" serialize-index ;

: generate-vocab-index ( -- )
    all-vocabs-really [ dup vocab-name ] map>alist
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

: vocab-apropos ( string -- results )
    "vocabs.idx" offline-apropos ;

: generate-qualified-index ( index -- )
    H{ } clone [
        '[
            over "," split1 nip ".html" ?tail drop
            [ swap ":" glue 2array ] [ _ push-at ] bi
        ] assoc-each
    ] keep [ swap ] { } assoc-map-as
    "qualified.idx" binary [ serialize ] with-file-writer ;

: qualified-index ( str index -- str index' )
    over ":" split1 [
        "qualified.idx"
        dup file-exists? [ pick generate-qualified-index ] unless
        load-index completions keys concat
    ] [ drop f ] if [ append ] unless-empty ;

: word-apropos ( string -- results )
    "words.idx" load-index qualified-index completions ;
