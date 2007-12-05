IN: xmode.marker
USING: kernel namespaces xmode.rules xmode.tokens
xmode.marker.state xmode.marker.context
xmode.utilities xmode.catalog sequences math
assocs combinators combinators.lib strings regexp splitting ;

! Based on org.gjt.sp.jedit.syntax.TokenMarker

: current-keyword ( -- string )
    last-offset get position get line get subseq ;

: keyword-number? ( keyword -- ? )
    {
        [ current-rule-set rule-set-highlight-digits? ]
        [ dup [ digit? ] contains? ]
        [
            dup [ digit? ] all? [
                current-rule-set rule-set-digit-re dup
                [ dupd 2drop f ] [ drop f ] if
            ] unless*
        ]
    } && nip ;

: mark-number ( keyword -- id )
    keyword-number? DIGIT and ;

: resolve-delegate ( name -- rules )
    dup string? [
        "::" split1 [ swap load-mode at ] [ rule-sets get at ] if*
    ] when ;

: rule-set-keyword-maps ( ruleset -- seq )
    dup rule-set-imports
    [ resolve-delegate rule-set-keyword-maps ] map concat
    swap rule-set-keywords add ;

: mark-keyword ( keyword -- id )
    current-rule-set rule-set-keyword-maps assoc-stack ;

: add-remaining-token ( -- )
    current-rule-set rule-set-default prev-token, ;

: mark-token ( -- )
    current-keyword
    dup mark-number [ ] [ mark-keyword ] ?if
    [ prev-token, ] when* ;

: check-terminate-char ( -- )
    current-rule-set rule-set-terminate-char [
        position get <= [
            terminated? on
        ] when
    ] when* ;

: current-char ( -- char )
    position get line get nth ;

GENERIC: match-position ( rule -- n )

M: mark-previous-rule match-position drop last-offset get ;

M: rule match-position drop position get ;

: can-match-here? ( matcher rule -- ? )
    match-position {
        [ over ]
        [ over matcher-at-line-start?     over zero?                implies ]
        [ over matcher-at-whitespace-end? over whitespace-end get = implies ]
        [ over matcher-at-word-start?     over last-offset get =    implies ]
    } && 2nip ;

GENERIC: text-matches? ( position text -- match-count/f )

M: f text-matches? 2drop f ;

M: string text-matches?
    ! XXX ignore case
    >r line get swap tail-slice r>
    [ head? ] keep length and ;

! M: regexp text-matches? ... ;

: rule-start-matches? ( rule -- match-count/f )
    dup rule-start tuck swap can-match-here? [
        position get swap matcher-text text-matches?
    ] [
        drop f
    ] if ;

: rule-end-matches? ( rule -- match-count/f )
    dup mark-following-rule? [
        dup rule-start swap can-match-here? 0 and
    ] [
        dup rule-end tuck swap can-match-here? [
            position get swap matcher-text
            context get line-context-end or
            text-matches?
        ] [
            drop f
        ] if
    ] if ;

DEFER: get-rules

: get-imported-rules ( vector/f char ruleset -- vector/f )
    rule-set-imports
    [ resolve-delegate get-rules ?push-all ] curry* each ;

: get-always-rules ( vector/f ruleset -- vector/f )
    f swap rule-set-rules at ?push-all ;

: get-char-rules ( vector/f char ruleset -- vector/f )
    >r ch>upper r> rule-set-rules at ?push-all ;

: get-rules ( char ruleset -- seq )
    f -rot
    [ get-char-rules ] 2keep
    [ get-always-rules ] keep
    get-imported-rules ;

GENERIC: handle-rule-start ( match-count rule -- )

GENERIC: handle-rule-end ( match-count rule -- )

: find-escape-rule ( -- rule )
    context get dup
    line-context-in-rule-set rule-set-escape-rule [ ] [
        line-context-parent line-context-in-rule-set
        dup [ rule-set-escape-rule ] when
    ] ?if ;

: check-escape-rule ( rule -- ? )
    rule-no-escape? [ f ] [
        find-escape-rule dup [
            dup rule-start-matches? dup [
                swap handle-rule-start
                delegate-end-escaped? [ not ] change
                t
            ] [
                2drop f
            ] if
        ] when
    ] if ;

: check-every-rule ( -- ? )
    current-char current-rule-set get-rules
    [ rule-start-matches? ] map-find
    dup [ handle-rule-start t ] [ 2drop f ] if ;

: ?end-rule ( -- )
    current-rule [
        dup rule-end-matches?
        dup [ swap handle-rule-end ] [ 2drop ] if
    ] when* ;

: rule-match-token* ( rule -- id )
    dup rule-match-token {
        { f [ dup rule-body-token ] }
        { t [ current-rule-set rule-set-default ] }
        [ ]
    } case nip ;

M: escape-rule handle-rule-start
    drop
    ?end-rule
    process-escape? get [
        escaped? [ not ] change
        position [ + ] change
    ] [ 2drop ] if ;

M: seq-rule handle-rule-start
    ?end-rule
    mark-token
    add-remaining-token
    tuck rule-body-token next-token,
    rule-delegate [ resolve-delegate push-context ] when* ;

UNION: abstract-span-rule span-rule eol-span-rule ;

M: abstract-span-rule handle-rule-start
    ?end-rule
    mark-token
    add-remaining-token
    tuck rule-match-token* next-token,
    ! ... end subst ...
    dup context get set-line-context-in-rule
    rule-delegate resolve-delegate push-context ;

M: span-rule handle-rule-end
    2drop ;

M: mark-following-rule handle-rule-start
    ?end-rule
    mark-token add-remaining-token
    tuck rule-match-token* next-token,
    f context get set-line-context-end
    context get set-line-context-in-rule ;

M: mark-following-rule handle-rule-end
    nip rule-match-token* prev-token,
    f context get set-line-context-in-rule ;

M: mark-previous-rule handle-rule-start
    ?end-rule
    mark-token
    dup rule-body-token prev-token,
    rule-match-token* next-token, ;

: do-escaped
    escaped? get [
        escaped? off
        ! ...
    ] when ;

: check-end-delegate ( -- ? )
    context get line-context-parent [
        line-context-in-rule [
            dup rule-end-matches? dup [
                [
                    swap handle-rule-end
                    ?end-rule
                    mark-token
                    add-remaining-token
                ] keep context get line-context-parent line-context-in-rule rule-match-token* next-token,
                pop-context
                seen-whitespace-end? on t
            ] [ drop check-escape-rule ] if
        ] [ f ] if*
    ] [ f ] if* ;

: handle-no-word-break ( -- )
    context get line-context-parent [
        line-context-in-rule dup rule-no-word-break? [
            rule-match-token* prev-token,
            pop-context
        ] [ drop ] if
    ] when* ;

: check-rule ( -- )
    ?end-rule
    handle-no-word-break
    mark-token
    add-remaining-token ;

: (check-word-break) ( -- )
    check-rule
    
    1 current-rule-set rule-set-default next-token, ;

: rule-set-empty? ( ruleset -- ? )
    dup rule-set-rules assoc-empty?
    swap rule-set-keywords assoc-empty? and ;

: check-word-break ( -- ? )
    current-char dup blank? [
        drop

        seen-whitespace-end? get [
            position get 1+ whitespace-end set
        ] unless

        (check-word-break)

    ] [
        ! Micro-optimization with incorrect semantics; we keep
        ! it here because jEdit mode files depend on it now...
        current-rule-set rule-set-empty? [
            drop
        ] [
            dup alpha? [
                drop
            ] [
                current-rule-set rule-set-no-word-sep* member? [
                    (check-word-break)
                ] unless
            ] if
        ] if

        seen-whitespace-end? on
    ] if
    escaped? off
    delegate-end-escaped? off t ;


: mark-token-loop ( -- )
    position get line get length < [
        check-terminate-char

        {
            [ check-end-delegate ]
            [ check-every-rule ]
            [ check-word-break ]
        } || drop

        position inc
        mark-token-loop
    ] when ;

: mark-remaining ( -- )
    line get length position set
    check-rule ;

: unwind-no-line-break ( -- )
    context get line-context-parent [
        line-context-in-rule rule-no-line-break?
        terminated? get or [
            pop-context
            unwind-no-line-break
        ] when
    ] when* ;

: tokenize-line ( line-context line rules -- line-context' seq )
    [
        init-token-marker
        mark-token-loop
        mark-remaining
        unwind-no-line-break
        context get
    ] { } make ;
