! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel combinators vocabs vocabs.loader
tools.vocabs io io.files io.styles help.markup help.stylesheet
sequences assocs help.topics namespaces prettyprint words
sorting definitions arrays summary sets generic ;
IN: tools.vocabs.browser

: vocab-status-string ( vocab -- string )
    {
        { [ dup not ] [ drop "" ] }
        { [ dup vocab-main ] [ drop "[Runnable]" ] }
        [ drop "[Loaded]" ]
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
    [ "Children from " prepend ] [ "Children" ] if*
    $heading ;

: vocabs. ( assoc -- )
    [
        [
            drop
        ] [
            swap root-heading.
            standard-table-style [
                vocab-headings. [ vocab. ] each
            ] ($grid)
        ] if-empty
    ] assoc-each ;

: describe-summary ( vocab -- )
    vocab-summary [
        "Summary" $heading print-element
    ] when* ;

TUPLE: vocab-tag name ;

INSTANCE: vocab-tag topic

C: <vocab-tag> vocab-tag

: tags. ( seq -- ) [ <vocab-tag> ] map $links ;

: describe-tags ( vocab -- )
    vocab-tags f like [
        "Tags" $heading tags.
    ] when* ;

TUPLE: vocab-author name ;

INSTANCE: vocab-author topic

C: <vocab-author> vocab-author

: authors. ( seq -- ) [ <vocab-author> ] map $links ;

: describe-authors ( vocab -- )
    vocab-authors f like [
        "Authors" $heading authors.
    ] when* ;

: describe-help ( vocab -- )
    vocab-help [
        "Documentation" $heading ($link)
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
    words [
        "Words" $heading
        natural-sort $links
    ] unless-empty ;

: vocab-xref ( vocab quot -- vocabs )
    >r dup vocab-name swap words [ generic? not ] filter r> map
    [ [ word? ] filter [ vocabulary>> ] map ] gather natural-sort
    remove sift ; inline

: vocab-uses ( vocab -- vocabs ) [ uses ] vocab-xref ;

: vocab-usage ( vocab -- vocabs ) [ usage ] vocab-xref ;

: describe-uses ( vocab -- )
    vocab-uses [
        "Uses" $heading
        $vocab-links
    ] unless-empty ;

: describe-usage ( vocab -- )
    vocab-usage [
        "Used by" $heading
        $vocab-links
    ] unless-empty ;

: $describe-vocab ( element -- )
    first
    dup describe-children
    dup find-vocab-root [
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
        [ >r 2dup r> swap call member? ] filter
        r> swap
    ] assoc-map 2nip ; inline

: tagged ( tag -- assoc )
    [ vocab-tags ] keyed-vocabs ;

: authored ( author -- assoc )
    [ vocab-authors ] keyed-vocabs ;

: $tagged-vocabs ( element -- )
    first tagged vocabs. ;

: $authored-vocabs ( element -- )
    first authored vocabs. ;

: $tags ( element -- )
    drop "Tags" $heading all-tags tags. ;

: $authors ( element -- )
    drop "Authors" $heading all-authors authors. ;

INSTANCE: vocab topic

INSTANCE: vocab-link topic

M: vocab-spec article-title vocab-name " vocabulary" append ;

M: vocab-spec article-name vocab-name ;

M: vocab-spec article-content
    vocab-name \ $describe-vocab swap 2array ;

M: vocab-spec article-parent drop "vocab-index" ;

M: vocab-tag >link ;

M: vocab-tag article-title
    name>> "Vocabularies tagged ``" swap "''" 3append ;

M: vocab-tag article-name name>> ;

M: vocab-tag article-content
    \ $tagged-vocabs swap name>> 2array ;

M: vocab-tag article-parent drop "vocab-index" ;

M: vocab-tag summary article-title ;

M: vocab-author >link ;

M: vocab-author article-title
    name>> "Vocabularies by " prepend ;

M: vocab-author article-name name>> ;

M: vocab-author article-content
    \ $authored-vocabs swap name>> 2array ;

M: vocab-author article-parent drop "vocab-index" ;

M: vocab-author summary article-title ;
