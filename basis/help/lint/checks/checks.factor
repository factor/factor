! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.struct
classes.tuple combinators combinators.short-circuit debugger
definitions effects eval formatting grouping help help.markup
help.topics io io.streams.string kernel macros math
math.statistics namespaces prettyprint sequences sequences.deep
sets splitting strings summary tools.destructors unicode vocabs
vocabs.loader words words.constant words.symbol ;
IN: help.lint.checks

ERROR: simple-lint-error message ;

M: simple-lint-error summary message>> ;

M: simple-lint-error error. summary print ;

SYMBOL: vocabs-quot
SYMBOL: vocab-articles

: no-ui-disposables ( seq -- seq' )
    [
        class-of name>> {
            "single-texture" "multi-texture" ! opengl.textures
            "line" ! core-text
            "layout" ! ui.text.pango
            "script-string" ! windows.uniscribe
            "linux-monitor" ! github issue #2014, race condition in disposing of child monitors
            "event-stream"
            "macos-monitor"
            "recursive-monitor"
            "input-port"
            "malloc-ptr"
            "fd"
            "win32-file"
            "win32-monitor"
            "win32-monitor-port"
        } member?
    ] reject ;

: check-example ( element -- )
    [
        '[
            _ rest [
                but-last join-lines
                (eval-with-stack>string)
                "\n" ?tail drop
            ] keep
            last assert=
        ] vocabs-quot get call( quot -- )
    ] leaks members no-ui-disposables
    dup length 0 > [
        dup [ class-of ] histogram-by
        [ "Leaked resources: " write ... ] with-string-writer simple-lint-error
    ] [
        drop
    ] if ;

: check-examples ( element -- )
    \ $example swap elements [ check-example ] each ;

: extract-values ( element -- seq )
    \ $values swap elements
    [ f ] [ first rest keys ] if-empty ;

: extract-value-effects ( element -- seq )
    \ $values swap elements [ f ] [
        first rest [
            \ $quotation swap elements [ f ] [
                first second dup effect? [ effect>string ] when
            ] if-empty
        ] map
    ] if-empty ;

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
        [ "help" word-prop not ]
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
    [ effect-effects ] [ extract-value-effects ] bi*
    [ 2dup and [ = ] [ 2drop t ] if ] 2all? [
        "$quotation stack effects in $values don't match"
        simple-lint-error
    ] unless ;

: check-see-also ( element -- )
    \ $see-also swap elements [ rest all-unique? ] all?
    [ "$see-also are not unique" simple-lint-error ] unless ;

: check-modules ( element -- )
    \ $vocab-link swap elements [
        second
        dup vocab-exists? [ drop ] [
            "$vocab-link to non-existent vocabulary ``" "''" surround
            simple-lint-error
        ] if
    ] each ;

: check-slots-tables ( element -- )
    \ $slots swap elements [ rest [ length 2 = ] all?  ] all?
    [ "$slots have too many values in at least one row" simple-lint-error ] unless ;

: check-rendering ( element -- )
    [ print-content ] with-string-writer drop ;

: check-strings ( str -- )
    [
        "\n\t" intersects? [
            "Paragraph text should not contain \\n or \\t"
            simple-lint-error
        ] when
    ] [
        "  " subseq-of? [
            "Paragraph text should not contain double spaces"
            simple-lint-error
        ] when
    ] bi ;

: check-whitespace ( str1 str2 -- )
    2dup [ ?last " (" member? ] [ ?first " ).,;:" member? ] bi* or
    [ 2drop ] [
        "Missing whitespace between strings ``%s'' and ``%s''"
        sprintf simple-lint-error
    ] if ;

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
        [
            dup struct-class? [ struct-slots ] [ all-slots ] if
            [ name>> ] map
        ] [ extract-slots ] bi*
        [ swap member? ] with reject [
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
        [ check-slots-tables ]
    } cleave ;

: files>vocabs ( -- assoc )
    loaded-vocab-names
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
