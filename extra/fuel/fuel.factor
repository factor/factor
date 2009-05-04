! Copyright (C) 2008, 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors assocs compiler.units continuations fuel.eval fuel.help
fuel.remote fuel.xref help.topics io.pathnames kernel namespaces parser
sequences tools.scaffold vocabs.loader words ;

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
SYMBOL: :uses-suggestions

: is-use-restart ( restart -- ? )
    name>> [ "Use the " head? ] [ " vocabulary" tail? ] bi and ;

: get-restart-vocab ( restart -- vocab/f )
    obj>> dup word? [ vocabulary>> ] [ drop f ] if ;

: is-suggested-restart ( restart -- ? )
    dup is-use-restart [
        get-restart-vocab :uses-suggestions get member?
    ] [ drop f ] if ;

: try-suggested-restarts ( -- )
    restarts get [ is-suggested-restart ] filter
    dup length 1 = [ first restart ] [ drop ] if ;

: fuel-set-use-hook ( -- )
    [ amended-use get clone :uses prefix fuel-eval-set-result ]
    print-use-hook set ;

: (fuel-get-uses) ( lines -- )
    [ parse-fresh drop ] curry with-compilation-unit ; inline

PRIVATE>

: fuel-use-suggested-vocabs ( suggestions quot -- ... )
    [ :uses-suggestions set ] dip
    [ try-suggested-restarts rethrow ] recover ; inline

: fuel-run-file ( path -- )
    [ fuel-set-use-hook run-file ] curry with-scope ; inline

: fuel-with-autouse ( ... quot: ( ... -- ... ) -- ... )
    [ auto-use? on fuel-set-use-hook call ] curry with-scope ; inline

: fuel-get-uses ( lines -- )
    [ (fuel-get-uses) ] curry fuel-with-autouse ;

! Edit locations

: fuel-get-word-location ( word -- )
    word-location fuel-eval-set-result ;

: fuel-get-vocab-location ( vocab -- )
    vocab-location fuel-eval-set-result ;

: fuel-get-doc-location ( word -- )
    doc-location fuel-eval-set-result ;

: fuel-get-article-location ( name -- )
    article-location fuel-eval-set-result ;

: fuel-get-vocabs ( -- )
    get-vocabs fuel-eval-set-result ;

: fuel-get-vocabs/prefix ( prefix -- )
    get-vocabs/prefix fuel-eval-set-result ;

: fuel-get-words ( prefix names -- )
    get-vocabs-words/prefix fuel-eval-set-result ;

! Cross-references

: fuel-callers-xref ( word -- ) callers-xref fuel-eval-set-result ;

: fuel-callees-xref ( word -- ) callees-xref fuel-eval-set-result ;

: fuel-apropos-xref ( str -- ) apropos-xref fuel-eval-set-result ;

: fuel-vocab-xref ( vocab -- ) vocab-xref fuel-eval-set-result ;

: fuel-vocab-uses-xref ( vocab -- ) vocab-uses-xref fuel-eval-set-result ;

: fuel-vocab-usage-xref ( vocab -- ) vocab-usage-xref fuel-eval-set-result ;

! Help support

: fuel-get-article ( name -- ) article fuel-eval-set-result ;

: fuel-get-article-title ( name -- )
    articles get at [ article-title ] [ f ] if* fuel-eval-set-result ;

: fuel-word-help ( name -- ) (fuel-word-help) fuel-eval-set-result ;

: fuel-word-see ( name -- ) (fuel-word-see) fuel-eval-set-result ;

: fuel-word-def ( name -- ) (fuel-word-def) fuel-eval-set-result ;

: fuel-vocab-help ( name -- ) (fuel-vocab-help) fuel-eval-set-result ;

: fuel-word-synopsis ( word usings -- ) (fuel-word-synopsis) fuel-eval-set-result ;

: fuel-vocab-summary ( name -- )
    (fuel-vocab-summary) fuel-eval-set-result ;

: fuel-index ( quot -- ) call( -- seq ) format-index fuel-eval-set-result ;

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

! Remote connection

MAIN: fuel-start-remote-listener*
