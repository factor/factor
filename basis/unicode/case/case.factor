! Copyright (C) 2008, 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: unicode.data sequences namespaces
sbufs make unicode.syntax unicode.normalize math hints
unicode.categories combinators unicode.syntax assocs combinators.short-circuit
strings splitting kernel accessors unicode.breaks fry locals ;
QUALIFIED: ascii
IN: unicode.case

<PRIVATE
: ch>lower ( ch -- lower ) simple-lower at-default ; inline
: ch>upper ( ch -- upper ) simple-upper at-default ; inline
: ch>title ( ch -- title ) simple-title at-default ; inline
PRIVATE>

SYMBOL: locale ! Just casing locale, or overall?

<PRIVATE

: split-subseq ( string sep -- strings )
    [ dup ] swap '[ _ split1-slice swap ] produce nip ;

: replace ( old new str -- newstr )
    [ split-subseq ] dip join ; inline

: i-dot? ( -- ? )
    locale get { "tr" "az" } member? ;

: lt? ( -- ? )
    locale get "lt" = ;

: lithuanian? ( -- ? ) locale get "lt" = ;

: dot-over ( -- ch ) HEX: 307 ;

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
        dup peek CHAR: greek-small-letter-sigma =
        [ 1 head* CHAR: greek-small-letter-final-sigma suffix ] when
    ] if-empty ; inline

: sigma-map ( string -- string )
    { CHAR: greek-capital-letter-sigma } split [ [
        [ { CHAR: greek-small-letter-sigma } ] [
            dup first uncased?
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
        dup special-casing at
        [ string-quot call out push-all ]
        [ char-quot call out push ] ?if
    ] each out "" like ; inline

PRIVATE>

: >lower ( string -- lower )
    i-dot? [ turk>lower ] when
    lt? [ lithuanian>lower ] when
    final-sigma
    [ lower>> ] [ ch>lower ] map-case ;

HINTS: >lower string ;

: >upper ( string -- upper )
    i-dot? [ turk>upper ] when
    lt? [ lithuanian>upper ] when
    [ upper>> ] [ ch>upper ] map-case ;

HINTS: >upper string ;

<PRIVATE

: (>title) ( string -- title )
    i-dot? [ turk>upper ] when
    lt? [ lithuanian>upper ] when
    [ title>> ] [ ch>title ] map-case ; inline

: title-word ( string -- title )
    unclip 1string [ >lower ] [ (>title) ] bi* prepend ; inline

PRIVATE>

: >title ( string -- title )
    final-sigma >words [ title-word ] map concat ;

HINTS: >title string ;

: >case-fold ( string -- fold )
    >upper >lower ;

: lower? ( string -- ? ) dup >lower = ;

: upper? ( string -- ? ) dup >upper = ;

: title? ( string -- ? ) dup >title = ;

: case-fold? ( string -- ? ) dup >case-fold = ;
