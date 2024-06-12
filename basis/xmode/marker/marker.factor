! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors ascii assocs combinators
combinators.short-circuit formatting kernel make math namespaces
regexp regexp.parser sequences splitting strings
xmode.marker.state xmode.rules xmode.tokens xmode.utilities ;

IN: xmode.marker

! Next two words copied from parser-combinators
! Just like head?, but they optionally ignore case

: string= ( str1 str2 ignore-case -- ? )
    [ [ >upper ] bi@ ] when sequence= ;

: string-head? ( str1 str2 ignore-case -- ? )
    2over shorter?
    [ 3drop f ] [
        [
            [ nip ]
            [ length head-slice ] 2bi
        ] dip string=
    ] if ;

! Based on org.gjt.sp.jedit.syntax.TokenMarker

: current-keyword ( -- string )
    last-offset get position get line get subseq ;

: keyword-number? ( keyword -- ? )
    {
        [ current-rule-set highlight-digits?>> ]
        [ dup [ digit? ] any? ]
        [
            dup [ digit? ] all? [
                current-rule-set digit-re>>
                [ dupd matches? ] [ f ] if*
            ] unless*
        ]
    } 0&& nip ;

: mark-number ( keyword -- id )
    keyword-number? DIGIT and ;

: mark-keyword ( keyword -- id )
    current-rule-set keywords>> at ;

: add-remaining-token ( -- )
    current-rule-set default>> prev-token, ;

: mark-token ( -- )
    current-keyword
    [ mark-number ] [ mark-keyword ] ?unless
    [ prev-token, ] when* ;

: current-char ( -- char )
    position get line get nth ;

GENERIC: match-position ( rule -- n )

M: mark-previous-rule match-position drop last-offset get ;

M: rule match-position drop position get ;

: can-match-here? ( matcher rule -- ? )
    match-position {
        [ over ]
        [ over at-line-start?>>     over zero?                implies ]
        [ over at-whitespace-end?>> over whitespace-end get = implies ]
        [ over at-word-start?>>     over last-offset get =    implies ]
    } 0&& 2nip ;

: rest-of-line ( -- str )
    line get position get tail-slice ;

: match-start ( string regexp -- slice/f )
    first-match dup [ dup from>> 0 = and* ] when ;

GENERIC: text-matches? ( string text -- match-count/f )

M: f text-matches?
    2drop f ;

M: string-matcher text-matches?
    [ string>> ] [ ignore-case?>> ] bi
    [ string-head? ] keepd length and ;

M: regexp text-matches?
    [ >string ] dip match-start dup [ to>> ] when ;

<PRIVATE

! XXX: Terrible inefficient regexp match group support

! XXX: support named-capturing groups?

: group-start ( i raw -- n/f )
    [ CHAR: ( -rot index-from ] keep 2dup
    { [ drop ] [ [ 1 + ] dip ?nth CHAR: ? = ] } 2&&
    [ [ 1 + ] dip group-start ] [ drop ] if ;

: nth-group-start ( n raw -- n )
    [ -1 ] 2dip '[ dup [ 1 + _ group-start ] when ] times ;

: matching-paren ( str -- to )
    0 swap [
        {
            { CHAR: ( [ 1 + ] }
            { CHAR: ) [ 1 - ] }
            [ drop ]
        } case dup zero?
    ] find drop nip ;

: nth-group ( n raw -- before nth )
    [ nth-group-start ] 1guard cut dup matching-paren 1 + head ;

: match-group-regexp ( regexp n -- skip-regexp match-regexp )
    [ [ options>> options>string ] [ raw>> ] bi ] dip swap
    nth-group rot '[ _ H{ } [ <optioned-regexp> ] 2cache ] bi@ ;

: skip-first-match ( match regexp -- tailseq )
    [ >string ] dip first-match [ seq>> ] [ to>> ] bi tail ;

: nth-match ( match regexp n -- slice/f )
    match-group-regexp [ skip-first-match ] [ match-start ] bi* ;

: update-match-groups ( str match regexp -- str' )
    pick CHAR: $ swap index [
        R/ [$]\d/ [ second CHAR: 0 - nth-match ] 2with re-replace-with
    ] [ 2drop ] if ;

GENERIC: fixup-end ( match regexp end -- end' )

M: string-matcher fixup-end
    [ string>> -rot update-match-groups ]
    [ ignore-case?>> ] bi <string-matcher> ;

MEMO: <fixup-regexp> ( raw matched options -- regexp )
    <optioned-regexp> {
        [ parse-tree>> ] [ options>> ] [ dfa>> ] [ next-match>> ]
    } cleave regexp boa ;

M: regexp fixup-end
    [ raw>> [ -rot update-match-groups ] 1guard ]
    [ options>> options>string ] bi <fixup-regexp> ;

: fixup-end? ( text -- ? )
    { [ regexp? ] [ 0 swap raw>> group-start ] } 1&& ;

: fixup-end/text-matches? ( string regexp rule -- match-count/f )
    [ >string ] 2dip [ [ match-start dup ] keep ] dip pick [
        end>> [ [ fixup-end ] change-text drop ] [ 2drop ] if*
    ] [
        3drop
    ] if dup [ to>> ] when ;

PRIVATE>

:: rule-start-matches? ( rule -- match-count/f )
    rule start>> dup rule can-match-here? [
        rest-of-line swap text>>
        dup fixup-end? [
            rule fixup-end/text-matches?
        ] [
            text-matches?
        ] if
    ] [
        drop f
    ] if ;

: rule-end-matches? ( rule -- match-count/f )
    dup mark-following-rule? [
        [ start>> ] keep can-match-here? 0 and
    ] [
        [ end>> dup ] keep can-match-here? [
            rest-of-line
            swap text>> context get end>> or
            text-matches?
        ] [
            drop f
        ] if
    ] if ;

DEFER: get-rules

: get-always-rules ( ruleset -- vector/f )
    f swap rules>> at ;

: get-char-rules ( char ruleset -- vector/f )
    [ ch>upper ] dip rules>> at ;

: get-rules ( char ruleset -- seq )
    [ get-char-rules ] [ get-always-rules ] bi [ append ] when* ;

GENERIC: handle-rule-start ( match-count rule -- )

GENERIC: handle-rule-end ( match-count rule -- )

: find-escape-rule ( -- rule )
    context get
    [ in-rule-set>> escape-rule>> ] [
        parent>> in-rule-set>>
        [ escape-rule>> ] ?call
    ] ?unless ;

: check-escape-rule ( rule -- ? )
    escape-rule>> [ find-escape-rule ] unless*
    dup [
        dup rule-start-matches? [
            swap handle-rule-start
            delegate-end-escaped? toggle
            t
        ] [
            drop f
        ] if*
    ] when ;

: check-every-rule ( -- ? )
    current-char current-rule-set get-rules
    [ rule-start-matches? ] map-find
    [ handle-rule-start t ] [ drop f ] if* ;

: ?end-rule ( -- )
    current-rule [
        dup rule-end-matches?
        [ swap handle-rule-end ] [ drop ] if*
    ] when* ;

: rule-match-token* ( rule -- id )
    dup match-token>> {
        { f [ dup body-token>> ] }
        { t [ current-rule-set default>> ] }
        [ ]
    } case nip ;

M: escape-rule handle-rule-start
    drop
    ?end-rule
    process-escape? get [
        escaped? toggle
        position [ + ] change
    ] [ drop ] if ;

M: seq-rule handle-rule-start
    ?end-rule
    mark-token
    add-remaining-token
    [ body-token>> next-token, ] keep
    delegate>> [ push-context ] when* ;

UNION: abstract-span-rule span-rule eol-span-rule ;

M: abstract-span-rule handle-rule-start
    ?end-rule
    mark-token
    add-remaining-token
    [ rule-match-token* next-token, ] keep
    ! ... end subst ...
    dup context get in-rule<<
    delegate>> push-context ;

M: span-rule handle-rule-end
    2drop ;

M: mark-following-rule handle-rule-start
    ?end-rule
    mark-token add-remaining-token
    [ rule-match-token* next-token, ] keep
    f context get end<<
    context get in-rule<< ;

M: mark-following-rule handle-rule-end
    nip rule-match-token* prev-token,
    f context get in-rule<< ;

M: mark-previous-rule handle-rule-start
    ?end-rule
    mark-token
    dup body-token>> prev-token,
    rule-match-token* next-token, ;

: do-escaped ( -- )
    escaped? get [
        escaped? off
        ! ...
    ] when ;

: check-end-delegate ( -- ? )
    context get parent>> [
        in-rule>> [
            dup rule-end-matches? [
                [
                    swap handle-rule-end
                    ?end-rule
                    mark-token
                    add-remaining-token
                ] keep context get parent>> in-rule>>
                rule-match-token* next-token,
                pop-context
                seen-whitespace-end? on t
            ] [ check-escape-rule ] if*
        ] [ f ] if*
    ] [ f ] if* ;

: handle-no-word-break ( -- )
    context get parent>> [
        in-rule>> [
            dup no-word-break?>> [
                rule-match-token* prev-token,
                pop-context
            ] [ drop ] if
        ] when*
    ] when* ;

: check-rule ( -- )
    ?end-rule
    handle-no-word-break
    mark-token
    add-remaining-token ;

: (check-word-break) ( -- )
    check-rule

    1 current-rule-set default>> next-token, ;

: rule-set-empty? ( ruleset -- ? )
    [ rules>> ] [ keywords>> ] bi
    [ assoc-empty? ] both? ;

: check-word-break ( -- ? )
    current-char dup blank? [
        drop

        seen-whitespace-end? get [
            position get 1 + whitespace-end set
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
        {
            [ check-end-delegate ]
            [ check-every-rule ]
            [ check-word-break ]
        } 0|| drop

        position inc
        mark-token-loop
    ] when ;

: mark-remaining ( -- )
    line get length position set
    check-rule ;

: unwind-no-line-break ( -- )
    context get parent>> [
        in-rule>> [
            no-line-break?>> [
                pop-context
                unwind-no-line-break
            ] when
        ] when*
    ] when* ;

: tokenize-line ( line-context line rules -- line-context' seq )
    [
        "MAIN" of -rot
        init-token-marker
        mark-token-loop
        mark-remaining
        unwind-no-line-break
        context get
    ] { } make ;
