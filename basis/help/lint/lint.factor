! Copyright (C) 2006, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs classes combinators command-line continuations
help help.lint.checks help.topics io kernel listener namespaces
parser sequences source-files.errors system tools.errors vocabs
vocabs.hierarchy vocabs.hierarchy.private vocabs.loader words ;
IN: help.lint

SYMBOL: lint-failures

lint-failures [ H{ } clone ] initialize

TUPLE: help-lint-error < source-file-error ;

SYMBOL: +help-lint-failure+

T{ error-type-holder
    { type +help-lint-failure+ }
    { word ":lint-failures" }
    { plural "help lint failures" }
    { icon "vocab:ui/tools/error-list/icons/help-lint-error.png" }
    { quot [ lint-failures get values ] }
    { forget-quot [ lint-failures get delete-at ] }
} define-error-type
M: help-lint-error error-type drop +help-lint-failure+ ;

<PRIVATE

: <help-lint-error> ( error topic -- help-lint-error )
    help-lint-error new-source-file-error ;

PRIVATE>

: notify-help-lint-error ( error topic -- )
    lint-failures get pick
    [ [ [ <help-lint-error> ] keep ] dip set-at ] [ delete-at drop ] if
    notify-error-observers ;

<PRIVATE

:: check-something ( topic quot -- )
    [ quot call( -- ) f ] [ ] recover
    topic notify-help-lint-error ; inline

: check-word ( word -- )
    [ with-file-vocabs ] vocabs-quot set
    dup "help" word-prop [
        [ >link ] keep '[
            _ dup "help" word-prop {
                [ check-values ]
                [ check-value-effects ]
                [ check-class-description ]
                [ nip check-see-also ]
                [ nip check-markup ]
            } 2cleave
        ] check-something
    ] [ drop ] if ;

: check-article ( article -- )
    [ with-interactive-vocabs ] vocabs-quot set
    >link dup '[
        _
        [ check-article-title ]
        [ article-content check-markup ] bi
    ] check-something ;

: check-about ( vocab -- )
    <vocab-link> dup
    '[ _ vocab-help [ lookup-article drop ] when* ] check-something ;

: help-lint-vocab ( vocab -- )
    "Checking " write dup vocab-name write "..." print flush
    [ check-about ]
    [ vocab-words [ check-word ] each ]
    [ vocab-articles get at [ check-article ] each ]
    tri ;

: help-lint-vocabs ( vocabs -- )
    [
        auto-use? off
        group-articles vocab-articles set
        [ help-lint-vocab ] each
    ] with-scope ;

PRIVATE>

: help-lint ( prefix -- )
    loaded-child-vocab-names help-lint-vocabs ;

: help-lint-root ( root -- )
    "" vocabs-to-load help-lint-vocabs ;

: help-lint-all ( -- ) "" help-lint ;

: :lint-failures ( -- ) lint-failures get values errors. ;

: unlinked-words ( vocab -- seq )
    vocab-words all-word-help [ article-parent ] reject ;

: linked-undocumented-words ( -- seq )
    all-words
    [ word-help ] reject
    [ article-parent ] filter
    [ predicate? ] reject ;

: test-lint-main ( -- )
    command-line get [
        dup vocab-roots get member? [
            [ load-root ] [ help-lint-root ] bi
        ] [
            [ load ] [ help-lint ] bi
        ] if
    ] each
    lint-failures get assoc-empty?
    [ [ "==== FAILING LINT" print :lint-failures flush ] unless ]
    [ 0 1 ? exit ] bi ;

MAIN: test-lint-main
