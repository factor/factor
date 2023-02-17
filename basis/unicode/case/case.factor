! Copyright (C) 2008, 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit kernel namespaces sbufs
sequences splitting unicode.categories unicode.data ;
QUALIFIED: ascii
IN: unicode.case

SYMBOL: locale ! Just casing locale, or overall?

<PRIVATE

: i-dot? ( locale -- ? )
    { "tr" "az" } member? ; inline

: lithuanian? ( locale -- ? ) "lt" = ; inline

: lithuanian>upper ( string -- lower )
    "i\u000307" "i" replace
    "j\u000307" "j" replace ;

: mark-above? ( ch -- ? )
    combining-class 230 = ;

:: with-rest ( seq quot: ( seq -- seq ) -- seq )
    seq unclip quot dip prefix ; inline

: add-dots ( seq -- seq )
    [ [ { } ] [
        [
            dup first
            { [ mark-above? ] [ CHAR: combining-ogonek = ] } 1||
            [ CHAR: combining-dot-above prefix ] when
        ] map
    ] if-empty ] with-rest ; inline

: lithuanian>lower ( string -- lower )
    "I" split add-dots "I" join
    "J" split add-dots "J" join ; inline

: turk>upper ( string -- upper-i )
    "i" "I\u000307" replace ; inline

: turk>lower ( string -- lower-i )
    "I\u000307" "i" replace
    "I" "\u000131" replace ; inline

: fix-sigma-end ( string -- string )
    [ "" ] [
        dup last CHAR: greek-small-letter-sigma =
        [ but-last CHAR: greek-small-letter-final-sigma suffix ] when
    ] if-empty ; inline

! this duplicate unicode to prevent dependencies
CATEGORY-NOT: (uncased) Lu Ll Lt Lm Mn Me ;

: sigma-map ( string -- string )
    { CHAR: greek-capital-letter-sigma } split [ [
        [ { CHAR: greek-small-letter-sigma } ] [
            dup first (uncased)?
            CHAR: greek-small-letter-final-sigma
            CHAR: greek-small-letter-sigma ? prefix
        ] if-empty
    ] map ] with-rest concat fix-sigma-end ; inline

: final-sigma ( string -- string )
    CHAR: greek-capital-letter-sigma
    over member? [ sigma-map ] when
    "" like ; inline

:: map-case ( string string-quot char-quot -- case )
    string length <sbuf> :> out
    string [
        [ special-case ]
        [ string-quot call out push-all ]
        [ char-quot call out push ] ?if
    ] each out "" like ; inline

: locale>lower ( string -- string' )
    locale get
    [ i-dot? [ turk>lower ] when ]
    [ lithuanian? [ lithuanian>lower ] when ] bi ;

: locale>upper ( string -- string' )
    locale get
    [ i-dot? [ turk>upper ] when ]
    [ lithuanian? [ lithuanian>upper ] when ] bi ;

PRIVATE>
