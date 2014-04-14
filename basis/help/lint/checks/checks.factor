! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.tuple combinators
combinators.short-circuit debugger definitions effects eval
formatting fry grouping help help.markup help.topics io io.streams.string
kernel macros math namespaces sequences sequences.deep sets splitting
strings summary threads tools.destructors unicode.categories vocabs vocabs.loader
words words.constant words.symbol ;
FROM: sets => members ;
IN: help.lint.checks

ERROR: simple-lint-error message ;

M: simple-lint-error summary message>> ;

M: simple-lint-error error. summary print ;

SYMBOL: vocabs-quot
SYMBOL: all-vocabs
SYMBOL: vocab-articles

: check-example ( element -- )
    [
        '[
            _ rest [
                but-last "\n" join
                [ (eval>string) ] call( code -- output )
                "\n" ?tail drop
            ] keep
            last assert=
        ] vocabs-quot get call( quot -- )
    ] leaks members length [
        "%d disposable(s) leaked in example" sprintf simple-lint-error
    ] unless-zero ;

: check-examples ( element -- )
    \ $example swap elements [ check-example ] each ;

: extract-values ( element -- seq )
    \ $values swap elements dup empty? [
        first rest keys
    ] unless ;

: extract-value-effects ( element -- seq )
    \ $values swap elements dup empty? [
        first rest [
            \ $quotation swap elements dup empty? [ drop f ] [
                first second
            ] if
        ] map
    ] unless ;

: effect-values ( word -- seq )
    stack-effect
    [ in>> ] [ out>> ] bi append
    [ dup pair? [ first ] when effect>string ] map members ;

: effect-effects ( word -- seq )
    stack-effect in>> [
        dup pair?
        [ second dup effect? [ effect>string ] [ drop f ] if ]
        [ drop f ] if
    ] map ;

: contains-funky-elements? ( element -- ? )
    {
        $shuffle
        $complex-shuffle
        $values-x/y
        $predicate
        $class-description
        $error-description
    } swap '[ _ elements empty? not ] any? ;

: don't-check-word? ( word -- ? )
    {
        [ macro? ]
        [ symbol? ]
        [ parsing-word? ]
        [ "declared-effect" word-prop not ]
        [ constant? ]
    } 1|| ;

: skip-check-values? ( word element -- ? )
    [ don't-check-word? ] [ contains-funky-elements? ] bi* or ;

: check-values ( word element -- )
    2dup skip-check-values? [ 2drop ] [
        [ effect-values ] [ extract-values ] bi* 2dup
        sequence= [ 2drop ] [
            "$values don't match stack effect; expected %u, got %u" sprintf
            simple-lint-error
        ] if
    ] if ;

: check-value-effects ( word element -- )
    [ effect-effects ]
    [ extract-value-effects ]
    bi* [ 2dup and [ = ] [ 2drop t ] if ] 2all?
    [ "$quotation documentation in $values don't match stack effect" simple-lint-error ]
    unless ;

: check-nulls ( element -- )
    \ $values swap elements
    null swap deep-member?
    [ "$values should not contain null" simple-lint-error ] when ;

: check-see-also ( element -- )
    \ $see-also swap elements [
        rest all-unique? t assert=
    ] each ;

: vocab-exists? ( name -- ? )
    [ lookup-vocab ] [ all-vocabs get member? ] bi or ;

: check-modules ( element -- )
    \ $vocab-link swap elements [
        second
        vocab-exists? [
            "$vocab-link to non-existent vocabulary"
            simple-lint-error
        ] unless
    ] each ;

: check-rendering ( element -- )
    [ print-content ] with-string-writer drop ;

: check-strings ( str -- )
    [
        "\n\t" intersects? [
            "Paragraph text should not contain \\n or \\t"
            simple-lint-error
        ] when
    ] [
        "  " swap subseq? [
            "Paragraph text should not contain double spaces"
            simple-lint-error
        ] when
    ] bi ;

: check-whitespace ( str1 str2 -- )
    [ " " tail? ] [ " " head? ] bi* or
    [ "Missing whitespace between strings" simple-lint-error ] unless ;

: check-bogus-nl ( element -- )
    { { $nl } { { $nl } } } [ head? ] with any? [
        "Simple element should not begin with a paragraph break"
        simple-lint-error
    ] when ;

: extract-slots ( elements -- seq )
    [ dup pair? [ first \ $slot = ] [ drop f ] if ] deep-filter
    [ second ] map ;

: check-class-description ( word element -- )
    \ $class-description swap elements over class? [
        [ all-slots [ name>> ] map ] [ extract-slots ] bi*
        [ swap member? not ] with filter [
            ", " join "Described $slot does not exist: " prepend
            simple-lint-error
        ] unless-empty
    ] [
        nip empty? not [
            "A word that is not a class has a $class-description"
            simple-lint-error
        ] when
    ] if ;

: check-article-title ( article -- )
    article-title first LETTER?
    [ "Article title must begin with a capital letter" simple-lint-error ] unless ;

: check-elements ( element -- )
    {
        [ check-bogus-nl ]
        [ [ string? ] filter [ check-strings ] each ]
        [ [ simple-element? ] filter [ check-elements ] each ]
        [ 2 <clumps> [ [ string? ] all? ] filter [ first2 check-whitespace ] each ]
    } cleave ;

: check-descriptions ( element -- )
    { $description $class-description $var-description }
    swap '[
        _ elements [
            rest { { } { "" } } member?
            [ "Empty $description" simple-lint-error ] when
        ] each
    ] each ;

: check-markup ( element -- )
    {
        [ check-elements ]
        [ check-rendering ]
        [ check-examples ]
        [ check-modules ]
        [ check-descriptions ]
    } cleave ;

: files>vocabs ( -- assoc )
    vocabs
    [ [ [ vocab-docs-path ] keep ] H{ } map>assoc ]
    [ [ [ vocab-source-path ] keep ] H{ } map>assoc ]
    bi assoc-union ;

: group-articles ( -- assoc )
    articles get keys
    files>vocabs
    H{ } clone [
        '[
            dup >link where dup
            [ first _ at _ push-at ] [ 2drop ] if
        ] each
    ] keep ;

: all-word-help ( words -- seq )
    [ word-help ] filter ;
