! Copyright (C) 2026 Factor developers.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.algebra
combinators.short-circuit effects help help.apropos help.markup
help.topics kernel locals sequences sorting strings vocabs words ;
IN: foogle

<PRIVATE

: documented-types ( word -- assoc )
    "help" word-prop \ $values swap elements
    [ H{ } ] [ first rest ] if-empty ;

:: slot-type ( slot docs -- type )
    slot pair? [ slot second ] [
        slot { [ classoid? ] [ effect? ] } 1||
        [ slot ] [ slot docs at ] if
    ] if dup { [ classoid? ] [ effect? ] } 1||
    [ drop object ] unless ;

: row-shape ( effect -- shape )
    [ in-var>> >boolean ]
    [ out-var>> >boolean ]
    [ [ in-var>> ] [ out-var>> ] bi = ] tri 3array ;

DEFER: matches-effect?

:: matches-slot? ( actual requested -- ? )
    requested object eq? [ t ] [
        requested effect? [
            actual effect? [ actual requested matches-effect? ] [ f ] if
        ] [
            actual classoid? [ actual requested class<= ] [ f ] if
        ] if
    ] if ;

:: matches-slots? ( actual requested -- ? )
    actual requested [ [ H{ } slot-type ] bi@ matches-slot? ] 2all? ;

:: matches-effect? ( actual requested -- ? )
    actual requested effect=
    actual requested [ row-shape ] bi@ = and [
        actual requested [ in>> ] bi@ matches-slots?
        actual requested [ out>> ] bi@ matches-slots? and
    ] [ f ] if ;

:: typed-effect ( eff docs -- typed )
    eff in>> [ docs slot-type ] map
    eff out>> [ docs slot-type ] map
    eff terminated?>> eff in-var>> eff out-var>> effect boa ;

:: matches-word? ( word requested -- ? )
    word stack-effect [
        word documented-types typed-effect requested matches-effect?
    ] [ f ] if* ;

PRIVATE>

:: foogle-in ( effect words -- matches )
    effect H{ } typed-effect :> requested
    words [ requested matches-word? ] filter
    [ [ vocabulary>> ] [ name>> ] bi 2array ] sort-by ;

: foogle ( effect -- matches ) all-words foogle-in ;

TUPLE: foogle-search effect ;
C: <foogle-search> foogle-search

M: foogle-search valid-article? drop t ;
M: foogle-search article-title effect>> effect>string "Foogle: " prepend ;
M: foogle-search article-content effect>> foogle \ $completions prefix ;
M: foogle-search >link ;
INSTANCE: foogle-search topic

: foogle. ( effect -- ) <foogle-search> print-topic ;
