! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces splitting sequences io.files kernel assocs
words vocabs vocabs.loader definitions parser continuations
inspector debugger io io.styles io.streams.lines hashtables
sorting prettyprint source-files arrays combinators strings
system math.parser help.markup help.topics help.syntax
help.stylesheet ;
IN: tools.browser

: vocab-summary-path ( vocab -- string )
    vocab-dir "summary.txt" path+ ;

: vocab-summary ( vocab -- summary )
    dup dup vocab-summary-path vocab-file-contents
    dup empty? [
        drop vocab-name " vocabulary" append
    ] [
        nip first
    ] if ;

M: vocab summary
    [
        dup vocab-summary %
        " (" %
        vocab-words assoc-size #
        " words)" %
    ] "" make ;

M: vocab-link summary vocab-summary ;

: set-vocab-summary ( string vocab -- )
    >r 1array r>
    dup vocab-summary-path
    set-vocab-file-contents ;

: vocab-tags-path ( vocab -- string )
    vocab-dir "tags.txt" path+ ;

: vocab-tags ( vocab -- tags )
    dup vocab-tags-path vocab-file-contents ;

: set-vocab-tags ( tags vocab -- )
    dup vocab-tags-path set-vocab-file-contents ;

: add-vocab-tags ( tags vocab -- )
    [ vocab-tags append prune ] keep set-vocab-tags ;

: vocab-authors-path ( vocab -- string )
    vocab-dir "authors.txt" path+ ;

: vocab-authors ( vocab -- authors )
    dup vocab-authors-path vocab-file-contents ;

: set-vocab-authors ( authors vocab -- )
    dup vocab-authors-path set-vocab-file-contents ;

: vocab-dir? ( root name -- ? )
    over [
        vocab-source path+ ?resource-path exists?
    ] [
        2drop f
    ] if ;

: subdirs ( dir -- dirs )
    directory [ second ] subset keys natural-sort ;

: (all-child-vocabs) ( root name -- vocabs )
    [ vocab-dir path+ ?resource-path subdirs ] keep
    dup empty? [
        drop
    ] [
        swap [ "." swap 3append ] curry* map
    ] if ;

: vocabs-in-dir ( root name -- )
    dupd (all-child-vocabs) [
        2dup vocab-dir? [ 2dup swap >vocab-link , ] when
        vocabs-in-dir
    ] curry* each ;

: sane-vocab-roots "." vocab-roots get remove ;

: all-vocabs ( -- assoc )
    sane-vocab-roots [
        dup [ "" vocabs-in-dir ] { } make
    ] { } map>assoc ;

: all-vocabs-seq ( -- seq )
    all-vocabs values concat ;

: dangerous? ( name -- ? )
    #! Hack
    {
        { [ "cpu." ?head ] [ t ] }
        { [ "io.unix" ?head ] [ t ] }
        { [ "io.windows" ?head ] [ t ] }
        { [ "ui.x11" ?head ] [ t ] }
        { [ "ui.windows" ?head ] [ t ] }
        { [ "ui.cocoa" ?head ] [ t ] }
        { [ "cocoa" ?head ] [ t ] }
        { [ "vocabs.loader.test" ?head ] [ t ] }
        { [ "editors." ?head ] [ t ] }
        { [ ".windows" ?tail ] [ t ] }
        { [ ".unix" ?tail ] [ t ] }
        { [ "unix." ?head ] [ t ] }
        { [ ".linux" ?tail ] [ t ] }
        { [ ".bsd" ?tail ] [ t ] }
        { [ ".macosx" ?tail ] [ t ] }
        { [ "windows." ?head ] [ t ] }
        { [ "cocoa" ?head ] [ t ] }
        { [ ".test" ?tail ] [ t ] }
        { [ dup "tools.deploy.app" = ] [ t ] }
        { [ t ] [ f ] }
    } cond nip ;

: load-everything ( -- )
    all-vocabs-seq
    [ vocab-name dangerous? not ] subset
    [ [ require ] each ] no-parse-hook ;

: unrooted-child-vocabs ( prefix -- seq )
    dup empty? [ CHAR: . add ] unless
    vocabs
    [ vocab-root not ] subset
    [
        vocab-name swap ?head CHAR: . rot member? not and
    ] curry* subset
    [ vocab ] map ;

: all-child-vocabs ( prefix -- assoc )
    sane-vocab-roots [
        dup pick dupd (all-child-vocabs)
        [ swap >vocab-link ] curry* map
    ] { } map>assoc
    f rot unrooted-child-vocabs 2array add ;

: load-children ( prefix -- )
    all-child-vocabs values concat
    [ [ require ] each ] no-parse-hook ;

: vocab-status-string ( vocab -- string )
    {
        { [ dup not ] [ drop "" ] }
        { [ dup vocab-main ] [ drop "[Runnable]" ] }
        { [ t ] [ drop "[Loaded]" ] }
    } cond ;

: write-status ( vocab -- )
    vocab vocab-status-string write ;

: vocab. ( vocab -- )
    [
        dup [ write-status ] with-cell
        dup [ ($link) ] with-cell
        [ vocab-summary write ] with-cell
    ] with-row ;

: vocab-headings. ( -- )
    [
        [ "State" write ] with-cell
        [ "Vocabulary" write ] with-cell
        [ "Summary" write ] with-cell
    ] with-row ;

: root-heading. ( root -- )
    [ "Children from " swap append ] [ "Children" ] if*
    $heading ;

: vocabs. ( assoc -- )
    [
        dup empty? [
            2drop
        ] [
            swap root-heading.
            standard-table-style [
                vocab-headings. [ vocab. ] each
            ] ($grid)
        ] if
    ] assoc-each ;

: describe-summary ( vocab -- )
    vocab-summary [
        "Summary" $heading print-element
    ] when* ;

TUPLE: vocab-tag name ;

C: <vocab-tag> vocab-tag

: tags. ( seq -- ) [ <vocab-tag> ] map $links ;

: describe-tags ( vocab -- )
    vocab-tags f like [
        "Tags" $heading tags.
    ] when* ;

TUPLE: vocab-author name ;

C: <vocab-author> vocab-author

: authors. ( seq -- ) [ <vocab-author> ] map $links ;

: describe-authors ( vocab -- )
    vocab-authors f like [
        "Authors" $heading authors.
    ] when* ;

: describe-help ( vocab -- )
    vocab-help [
        "Documentation" $heading nl ($link)
    ] when* ;

: describe-children ( vocab -- )
    vocab-name all-child-vocabs vocabs. ;

: describe-files ( vocab -- )
    vocab-files [ <pathname> ] map [
        "Files" $heading
        [
            snippet-style get [
                code-style get [
                    stack.
                ] with-nesting
            ] with-style
        ] ($block)
    ] when* ;

: describe-words ( vocab -- )
    words dup empty? [
        "Words" $heading
        dup natural-sort $links
    ] unless drop ;

: map>set ( seq quot -- )
    map concat prune natural-sort ; inline

: vocab-xref ( vocab quot -- vocabs )
    >r dup vocab-name swap words r> map
    [ [ word? ] subset [ word-vocabulary ] map ] map>set
    remove [ vocab ] map ; inline

: vocab-uses ( vocab -- vocabs ) [ uses ] vocab-xref ;

: vocab-usage ( vocab -- vocabs ) [ usage ] vocab-xref ;

: describe-uses ( vocab -- )
    vocab-uses dup empty? [
        "Uses" $heading
        dup $links
    ] unless drop ;

: describe-usage ( vocab -- )
    vocab-usage dup empty? [
        "Used by" $heading
        dup $links
    ] unless drop ;

: $describe-vocab ( element -- )
    first
    dup describe-children
    dup vocab-root over vocab-dir? [
        dup describe-summary
        dup describe-tags
        dup describe-authors
        dup describe-files
    ] when
    dup vocab [
        dup describe-help
        dup describe-words
        dup describe-uses
        dup describe-usage
    ] when drop ;

: keyed-vocabs ( str quot -- seq )
    all-vocabs [
        swap >r
        [ >r 2dup r> swap call member? ] subset
        r> swap
    ] assoc-map 2nip ; inline

: tagged ( tag -- assoc )
    [ vocab-tags ] keyed-vocabs ;

: authored ( author -- assoc )
    [ vocab-authors ] keyed-vocabs ;

: $tagged-vocabs ( element -- )
    first tagged vocabs. ;

: all-tags ( vocabs -- seq ) [ vocab-tags ] map>set ;

: $authored-vocabs ( element -- )
    first authored vocabs. ;

: all-authors ( vocabs -- seq ) [ vocab-authors ] map>set ;

: $tags,authors ( element -- )
    drop
    all-vocabs-seq
    "Tags" $heading
    dup all-tags tags.
    "Authors" $heading
    all-authors authors. ;

ARTICLE: "vocab-index" "Vocabulary index"
{ $tags,authors }
{ $describe-vocab "" } ;

M: vocab-spec article-title vocab-name " vocabulary" append ;

M: vocab-spec article-name vocab-name ;

M: vocab-spec article-content
    vocab-name \ $describe-vocab swap 2array ;

M: vocab-spec article-parent drop "vocab-index" ;

M: vocab-tag >link ;

M: vocab-tag article-title
    vocab-tag-name "Vocabularies tagged ``" swap "''" 3append ;

M: vocab-tag article-name vocab-tag-name ;

M: vocab-tag article-content
    \ $tagged-vocabs swap vocab-tag-name 2array ;

M: vocab-tag article-parent drop "vocab-index" ;

M: vocab-tag summary article-title ;

M: vocab-author >link ;

M: vocab-author article-title
    vocab-author-name "Vocabularies by " swap append ;

M: vocab-author article-name vocab-author-name ;

M: vocab-author article-content
    \ $authored-vocabs swap vocab-author-name 2array ;

M: vocab-author article-parent drop "vocab-index" ;

M: vocab-author summary article-title ;
