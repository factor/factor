! Copyright (C) 2008, 2009 Jose Antonio Ortega Ruiz.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.units continuations fry fuel.eval
fuel.help fuel.xref help.topics io.pathnames kernel namespaces parser
parser.notes sequences source-files tools.scaffold vocabs vocabs.files
vocabs.hierarchy vocabs.loader vocabs.metadata vocabs.parser words ;
IN: fuel

! Evaluation
: fuel-eval-restartable ( -- )
    t eval-res-flag set-global ; inline

: fuel-eval-non-restartable ( -- )
    f eval-res-flag set-global ; inline

: fuel-eval-in-context ( lines in usings -- )
    eval-in-context ;

: fuel-retort ( -- ) f f "" send-retort ; inline

! Loading files

<PRIVATE

SYMBOL: :uses
SYMBOL: :uses-suggestions

: is-use-restart? ( restart -- ? )
    name>> [ "Use the " head? ] [ " vocabulary" tail? ] bi and ;

: get-restart-vocab ( restart -- vocab/f )
    obj>> dup word? [ vocabulary>> ] [ drop f ] if ;

: is-suggested-restart? ( restart -- ? )
    dup is-use-restart? [
        get-restart-vocab :uses-suggestions get member?
    ] [ drop f ] if ;

: try-suggested-restarts ( -- )
    restarts get [ is-suggested-restart? ] filter
    dup length 1 = [ first continue-restart ] [ drop ] if ;

SYMBOL: auto-uses

: set-use-hook ( -- )
    [
        manifest get auto-used>> clone :uses prefix
        clone auto-uses set-global
    ] print-use-hook set ;

PRIVATE>

: fuel-use-suggested-vocabs ( ..a suggestions quot: ( ..a -- ..b )
                              -- ..b result )
    f auto-uses set-global
    [ :uses-suggestions set ] dip
    [ try-suggested-restarts rethrow ] recover
    auto-uses get-global ; inline

: fuel-run-file ( path -- result )
    f auto-uses set-global
    '[ set-use-hook _ run-file ] with-scope
    auto-uses get-global ; inline

: fuel-with-autouse ( ..a quot: ( ..a -- ..b ) -- ..b )
    '[ set-use-hook _ call ] with-scope ; inline

: fuel-get-uses ( name lines -- )
    '[
        [
            _ [
                parser-quiet? on
                _ parse-fresh drop
            ] with-source-file
        ] with-compilation-unit
    ] fuel-with-autouse ;

! Edit locations
: fuel-get-word-location ( word -- result )
    word-location ;

: fuel-get-vocab-location ( vocab -- result )
    vocab-location  ;

: fuel-get-doc-location ( word -- result )
    doc-location ;

: fuel-get-article-location ( name -- result )
    article-location ;

: fuel-get-vocabs ( -- reuslt )
    all-disk-vocab-names ;

: fuel-get-vocabs/prefix ( prefix -- result )
    get-vocabs/prefix ;

: fuel-get-words ( prefix names -- result )
    get-vocabs-words/prefix ;

! Cross-references

: fuel-callers-xref ( word -- result ) callers-xref ;

: fuel-callees-xref ( word -- result ) callees-xref ;

: fuel-apropos-xref ( str -- result ) apropos-xref ;

: fuel-vocab-xref ( vocab -- result ) vocab-xref ;

: fuel-vocab-uses-xref ( vocab -- result ) vocab-uses-xref ;

: fuel-vocab-usage-xref ( vocab -- result ) vocab-usage-xref ;

! Help support

: fuel-get-article ( name -- result )
    fuel.help:get-article ;

: fuel-get-article-title ( name -- result )
    articles get at [ article-title ] [ f ] if* ;

: fuel-word-help ( name -- result ) word-help ;

: fuel-word-def ( name -- result ) word-def ;

: fuel-vocab-help ( name -- result ) fuel.help:vocab-help ;

: fuel-word-synopsis ( word -- synopsis )
    word-synopsis ;

: fuel-vocab-summary ( name -- summary )
    fuel.help:vocab-summary ;

: fuel-index ( quot -- result )
    call( -- seq ) format-index ;

: fuel-get-vocabs/tag ( tag -- result )
    get-vocabs/tag ;

: fuel-get-vocabs/author ( author -- result )
    get-vocabs/author ;

! Scaffold support

: scaffold-name ( devname -- )
    [ developer-name set ] when* ;

: fuel-scaffold-vocab ( root name devname -- result )
    [ scaffold-name dup [ scaffold-vocab-in ] dip ] with-scope
    dup require vocab-source-path absolute-path ;

: fuel-scaffold-help ( name devname -- result )
    [ scaffold-name dup require dup scaffold-docs ] with-scope
    vocab-docs-path absolute-path ;

: fuel-scaffold-tests ( name devname -- result )
    [ scaffold-name dup require dup scaffold-tests ] with-scope
    vocab-tests-path absolute-path ;

: fuel-scaffold-authors ( name devname -- result )
    [ scaffold-name dup require dup scaffold-authors ] with-scope
    vocab-authors-path absolute-path ;

: fuel-scaffold-tags ( name tags -- result )
    [ scaffold-tags ]
    [ drop vocab-tags-path absolute-path ] 2bi ;

: fuel-scaffold-summary ( name summary -- result )
    [ scaffold-summary ]
    [ drop vocab-summary-path absolute-path ] 2bi ;

: fuel-scaffold-platforms ( name platforms -- result )
    [ scaffold-platforms ]
    [ drop vocab-platforms-path absolute-path ] 2bi ;

: fuel-scaffold-get-root ( name -- result )
    find-vocab-root ;
