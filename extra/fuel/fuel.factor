! Copyright (C) 2008, 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs compiler.units definitions fuel.eval
fuel.help help.markup help.topics io.pathnames kernel math math.order
memoize namespaces parser sequences sets sorting tools.crossref
tools.scaffold tools.vocabs vocabs vocabs.loader vocabs.parser words ;

IN: fuel

! Evaluation

: fuel-eval-restartable ( -- )
    t fuel-eval-res-flag set-global ; inline

: fuel-eval-non-restartable ( -- )
    f fuel-eval-res-flag set-global ; inline

: fuel-eval-in-context ( lines in usings -- )
    (fuel-eval-in-context) ;

: fuel-eval-set-result ( obj -- )
    clone fuel-eval-result set-global ; inline

: fuel-retort ( -- ) fuel-send-retort ; inline

! Loading files

<PRIVATE

SYMBOL: :uses

: fuel-set-use-hook ( -- )
    [ amended-use get clone :uses prefix fuel-eval-set-result ]
    print-use-hook set ;

: (fuel-get-uses) ( lines -- )
    [ parse-fresh drop ] curry with-compilation-unit ; inline

PRIVATE>

: fuel-run-file ( path -- )
    [ fuel-set-use-hook run-file ] curry with-scope ; inline

: fuel-with-autouse ( ... quot: ( ... -- ... ) -- ... )
    [ auto-use? on fuel-set-use-hook call ] curry with-scope ; inline

: fuel-get-uses ( lines -- )
    [ (fuel-get-uses) ] curry fuel-with-autouse ;

! Edit locations

<PRIVATE

: fuel-normalize-loc ( seq -- path line )
    [ dup length 0 > [ first (normalize-path) ] [ drop f ] if ]
    [ dup length 1 > [ second ] [ drop 1 ] if ] bi ;

: fuel-get-loc ( object -- )
    fuel-normalize-loc 2array fuel-eval-set-result ;

PRIVATE>

: fuel-get-edit-location ( word -- ) where fuel-get-loc ; inline

: fuel-get-vocab-location ( vocab -- )
    >vocab-link fuel-get-edit-location ; inline

: fuel-get-doc-location ( word -- ) props>> "help-loc" swap at fuel-get-loc ;

: fuel-get-article-location ( name -- ) article loc>> fuel-get-loc ;

! Cross-references

<PRIVATE

: fuel-word>xref ( word -- xref )
    [ name>> ] [ vocabulary>> ] [ where fuel-normalize-loc ] tri 4array ;

: fuel-sort-xrefs ( seq -- seq' )
    [ [ first ] dip first <=> ] sort ; inline

: fuel-format-xrefs ( seq -- seq' )
    [ word? ] filter [ fuel-word>xref ] map ; inline

: (fuel-index) ( seq -- seq )
    [ [ >link name>> ] [ article-title ] bi 2array \ $subsection prefix ] map ;

PRIVATE>

: fuel-callers-xref ( word -- )
    usage fuel-format-xrefs fuel-sort-xrefs fuel-eval-set-result ; inline

: fuel-callees-xref ( word -- )
    uses fuel-format-xrefs fuel-sort-xrefs fuel-eval-set-result ; inline

: fuel-apropos-xref ( str -- )
    words-matching fuel-format-xrefs fuel-eval-set-result ; inline

: fuel-vocab-xref ( vocab -- )
    words fuel-format-xrefs fuel-eval-set-result ; inline

: fuel-index ( quot: ( -- seq ) -- )
    call (fuel-index) fuel-eval-set-result ; inline

! Completion support

<PRIVATE

: fuel-filter-prefix ( seq prefix -- seq )
    [ drop-prefix nip length 0 = ] curry filter prune ; inline

: (fuel-get-vocabs) ( -- seq )
    all-vocabs-seq [ vocab-name ] map ; inline

MEMO: (fuel-vocab-words) ( name -- seq )
    >vocab-link words [ name>> ] map ;

: fuel-current-words ( -- seq )
    use get [ keys ] map concat ; inline

: fuel-vocabs-words ( names -- seq )
    prune [ (fuel-vocab-words) ] map concat ; inline

: (fuel-get-words) ( prefix names/f -- seq )
    [ fuel-vocabs-words ] [ fuel-current-words ] if* natural-sort
    swap fuel-filter-prefix ;

PRIVATE>

: fuel-get-vocabs ( -- )
    (fuel-get-vocabs) fuel-eval-set-result ;

: fuel-get-vocabs/prefix ( prefix -- )
    (fuel-get-vocabs) swap fuel-filter-prefix fuel-eval-set-result ;

: fuel-get-words ( prefix names -- )
    (fuel-get-words) fuel-eval-set-result ;

! Help support

: fuel-get-article ( name -- ) article fuel-eval-set-result ;

: fuel-get-article-title ( name -- )
    articles get at [ article-title ] [ f ] if* fuel-eval-set-result ;

: fuel-word-help ( name -- ) (fuel-word-help) fuel-eval-set-result ;

: fuel-word-see ( name -- ) (fuel-word-see) fuel-eval-set-result ;

: fuel-word-def ( name -- ) (fuel-word-def) fuel-eval-set-result ;

: fuel-vocab-help ( name -- ) (fuel-vocab-help) fuel-eval-set-result ;

: fuel-vocab-summary ( name -- )
    (fuel-vocab-summary) fuel-eval-set-result ;

: fuel-get-vocabs/tag ( tag -- )
    (fuel-get-vocabs/tag) fuel-eval-set-result ;

: fuel-get-vocabs/author ( author -- )
    (fuel-get-vocabs/author) fuel-eval-set-result ;

! Scaffold support

: fuel-scaffold-vocab ( root name devname -- )
    developer-name set dup [ scaffold-vocab ] dip
    dup require vocab-source-path (normalize-path) fuel-eval-set-result ;

: fuel-scaffold-help ( name devname -- )
    developer-name set
    dup require dup scaffold-help vocab-docs-path
    (normalize-path) fuel-eval-set-result ;

: fuel-scaffold-get-root ( name -- ) find-vocab-root fuel-eval-set-result ;

