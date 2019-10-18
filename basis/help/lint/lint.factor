! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs classes combinators command-line continuations fry
help help.lint.checks help.topics io kernel listener locals
namespaces parser sequences source-files.errors system
tools.errors vocabs vocabs.hierarchy ;
IN: help.lint

SYMBOL: lint-failures

lint-failures [ H{ } clone ] initialize

TUPLE: help-lint-error < source-file-error ;

SYMBOL: +help-lint-failure+

T{ error-type-holder
   { type +help-lint-failure+ }
   { word ":lint-failures" }
   { plural "help lint failures" }
   { icon "vocab:ui/tools/error-list/icons/help-lint-error.tiff" }
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
    dup word-help [
        [ >link ] keep '[
            _ dup word-help {
                [ check-values ]
                [ check-value-effects ]
                [ check-class-description ]
                [ nip [ check-nulls ] [ check-see-also ] [ check-markup ] tri ]
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

: check-vocab ( vocab -- )
    "Checking " write dup write "..." print flush
    [ check-about ]
    [ vocab-words [ check-word ] each ]
    [ vocab-articles get at [ check-article ] each ]
    tri ;

PRIVATE>

: help-lint ( prefix -- )
    [
        auto-use? off
        group-articles vocab-articles set
        loaded-child-vocab-names
        [ check-vocab ] each
    ] with-scope ;

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
    command-line get [ load ] each
    help-lint-all
    lint-failures get assoc-empty?
    [ [ "==== FAILING LINT" print :lint-failures flush ] unless ]
    [ 0 1 ? exit ] bi ;

MAIN: test-lint-main
