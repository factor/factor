! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: unicode.data sequences sequences.next namespaces make
unicode.normalize math unicode.categories combinators unicode.syntax
assocs strings splitting kernel accessors unicode.breaks fry ;
IN: unicode.case

<PRIVATE
: at-default ( key assoc -- value/key ) [ at ] [ drop ] 2bi or ;

: ch>lower ( ch -- lower ) simple-lower at-default ;
: ch>upper ( ch -- upper ) simple-upper at-default ;
: ch>title ( ch -- title ) simple-title at-default ;
PRIVATE>

SYMBOL: locale ! Just casing locale, or overall?

<PRIVATE

: split-subseq ( string sep -- strings )
    [ dup ] swap '[ _ split1-slice swap ] [ ] produce nip ;

: replace ( old new str -- newstr )
    [ split-subseq ] dip join ;

: i-dot? ( -- ? )
    locale get { "tr" "az" } member? ;

: lithuanian? ( -- ? ) locale get "lt" = ;

: dot-over ( -- ch ) HEX: 307 ;

: lithuanian>upper ( string -- lower )
    "i\u000307" "i" replace
    "j\u000307" "j" replace ;

: mark-above? ( ch -- ? )
    combining-class 230 = ;

: with-rest ( seq quot: ( seq -- seq ) -- seq )
    [ unclip ] dip swap slip prefix ; inline

: add-dots ( seq -- seq )
    [ [ "" ] [
        dup first mark-above?
        [ CHAR: combining-dot-above prefix ] when
    ] if-empty ] with-rest ;

: lithuanian>lower ( string -- lower )
    "i" split add-dots "i" join
    "j" split add-dots "i" join ;

: turk>upper ( string -- upper-i )
    "i" "I\u000307" replace ;

: turk>lower ( string -- lower-i )
    "I\u000307" "i" replace
    "I" "\u000131" replace ;

: fix-sigma-end ( string -- string )
    [ "" ] [
        dup peek CHAR: greek-small-letter-sigma =
        [ 1 head* CHAR: greek-small-letter-final-sigma suffix ] when
    ] if-empty ;

: sigma-map ( string -- string )
    { CHAR: greek-capital-letter-sigma } split [ [
        [ { CHAR: greek-small-letter-sigma } ] [
            dup first uncased?
            CHAR: greek-small-letter-final-sigma
            CHAR: greek-small-letter-sigma ? prefix
        ] if-empty
    ] map ] with-rest concat fix-sigma-end ;

: final-sigma ( string -- string )
    CHAR: greek-capital-letter-sigma
    over member? [ sigma-map ] when ;

: map-case ( string string-quot char-quot -- case )
    [
        [
            [ dup special-casing at ] 2dip
            [ [ % ] compose ] [ [ , ] compose ] bi* ?if
        ] 2curry each
    ] "" make ; inline

PRIVATE>

: >lower ( string -- lower )
    i-dot? [ turk>lower ] when final-sigma
    [ lower>> ] [ ch>lower ] map-case ;

: >upper ( string -- upper )
    i-dot? [ turk>upper ] when
    [ upper>> ] [ ch>upper ] map-case ;

<PRIVATE

: (>title) ( string -- title )
    i-dot? [ turk>upper ] when
    [ title>> ] [ ch>title ] map-case ;

: title-word ( string -- title )
    unclip 1string [ >lower ] [ (>title) ] bi* prepend ;

PRIVATE>

: >title ( string -- title )
    final-sigma >words [ title-word ] map concat ;

: >case-fold ( string -- fold )
    >upper >lower ;

: lower? ( string -- ? ) dup >lower = ;

: upper? ( string -- ? ) dup >upper = ;

: title? ( string -- ? ) dup >title = ;

: case-fold? ( string -- ? ) dup >case-fold = ;
