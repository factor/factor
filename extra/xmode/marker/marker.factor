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

: mark-keyword ( keyword -- id )
    current-keywords at ;

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

GENERIC: perform-rule ( rule -- )

: ... ;

M: escape-rule perform-rule ( rule -- ) ... ;

: find-escape-rule ( -- rule )
    context get dup
    line-context-in-rule-set rule-set-escape-rule
    [ ] [ line-context-parent find-escape-rule ] ?if ;

: check-escape-rule ( rule -- )
    #! Unlike jEdit, we keep checking parents until we find
    #! an escape rule.
    dup rule-no-escape? [ drop ] [
        drop
        ! find-escape-rule
        ! current-rule-set rule-set-escape-rule [
        !     find-escape-rule
        ! ] [
        !     
        ! ] if*
    ] if ;

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

: matches-not-mark-following? ... ;

GENERIC: text-matches? ( position text -- match-count/f )

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
        dup rule-end swap can-match-here? 0 and
    ] [
        dup rule-end tuck swap can-match-here? [
            position get swap matcher-text
            context get line-context-end or
            text-matches?
        ] [
            drop f
        ] if
    ] if ;

GENERIC: handle-rule-start ( match-count rule -- )

GENERIC: handle-rule-end ( match-count rule -- )

: check-every-rule ( -- ? )
    current-char current-rule-set get-rules
    [ rule-start-matches? ] map-find
    dup [ handle-rule-start t ] [ 2drop f ] if ;

: ?end-rule ( -- )
    current-rule [
        dup rule-end-matches?
        dup [ swap handle-rule-end ] [ 2drop ] if
    ] when* ;

: handle-escape-rule ( rule -- )
    ?end-rule
    ;
!        ... process escape ... ;

: rule-match-token* ( rule -- id )
    dup rule-match-token {
        { f [ dup rule-body-token ] }
        { t [ current-rule-set rule-set-default ] }
        [ ]
    } case nip ;

: resolve-delegate ( name -- rules )
    dup string? [
        "::" split1 [ swap load-mode at ] [ rule-sets get at ] if*
    ] when ;

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

M: mark-previous-rule handle-rule-start
    ?end-rule
    mark-token
    dup rule-body-token prev-token,
    rule-match-token* next-token, ;

: do-escaped
    escaped? get [
        escaped? off
        ...
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
            ] [ 2drop f ] if
        ] [ f ] if*
    ] [ f ] if* ;

: handle-no-word-break ( -- )
    context get line-context-parent [
        line-context-in-rule dup rule-no-word-break? [
            rule-match-token prev-token,
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

: check-word-break ( -- ? )
    current-char dup blank? [
        drop

        seen-whitespace-end? get [
            position get 1+ whitespace-end set
        ] unless

        (check-word-break)

    ] [
        dup alpha? [
            drop
        ] [
            dup current-rule-set dup short. rule-set-no-word-sep* dup . member? [
                "A: " write write1 nl
            ] [
                "B: " write write1 nl
                (check-word-break)
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
