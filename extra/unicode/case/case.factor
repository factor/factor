USING: kernel unicode.data sequences sequences.next namespaces assocs.lib
unicode.normalize math unicode.categories combinators assocs ;
IN: unicode.case

: ch>lower ( ch -- lower ) simple-lower at-default ;
: ch>upper ( ch -- upper ) simple-upper at-default ;
: ch>title ( ch -- title ) simple-title at-default ;

SYMBOL: locale ! Just casing locale, or overall?

: i-dot? ( -- ? )
    locale get { "tr" "az" } member? ;

: lithuanian? ( -- ? ) locale get "lt" = ;

: dot-over ( -- ch ) HEX: 307 ;

: lithuanian-ch>upper ( ? next ch -- ? )
    rot [ 2drop f ]
    [ swap dot-over = over "ij" member? and swap , ] if ;

: lithuanian>upper ( string -- lower )
    [ f swap [ lithuanian-ch>upper ] each-next drop ] "" make* ;

: mark-above? ( ch -- ? )
    combining-class 230 = ;

: lithuanian-ch>lower ( next ch -- )
    ! This fails to add a dot above in certain edge cases
    ! where there is a non-above combining mark before an above one
    ! in Lithuanian
    dup , "IJ" member? swap mark-above? and [ dot-over , ] when ;

: lithuanian>lower ( string -- lower )
    [ [ lithuanian-ch>lower ] each-next ] "" make* ;

: turk-ch>upper ( ch -- )
    dup CHAR: i = 
    [ drop CHAR: I , dot-over , ] [ , ] if ;

: turk>upper ( string -- upper-i )
    [ [ turk-ch>upper ] each ] "" make* ;

: turk-ch>lower ( ? next ch -- ? )
    {
        { [ rot ] [ 2drop f ] }
        { [ dup CHAR: I = ] [
            drop dot-over =
            dup CHAR: i HEX: 131 ? ,
        ] }
        { [ t ] [ , drop f ] }
    } cond ;

: turk>lower ( string -- lower-i )
    [ f swap [ turk-ch>lower ] each-next drop ] "" make* ;

: word-boundary ( prev char -- new ? )
    dup non-starter? [ drop dup ] when
    swap uncased? ;

: sigma-map ( string -- string )
    [
        swap [ uncased? ] keep not or
        [ drop HEX: 3C2 ] when
    ] map-next ;

: final-sigma ( string -- string )
    HEX: 3A3 over member? [ sigma-map ] when ;

: map-case ( string string-quot char-quot -- case )
    [
        rot [
            -rot [
                rot dup special-casing at
                [ -rot drop call % ]
                [ -rot nip call , ] ?if
            ] 2keep
        ] each 2drop
    ] "" make* ; inline

: >lower ( string -- lower )
    i-dot? [ turk>lower ] when
    final-sigma [ code-point-lower ] [ ch>lower ] map-case ;

: >upper ( string -- upper )
    i-dot? [ turk>upper ] when
    [ code-point-upper ] [ ch>upper ] map-case ;

: >title ( string -- title )
    final-sigma
    CHAR: \s swap
    [ tuck word-boundary swapd
        [ code-point-title ] [ code-point-lower ] if ]
    [ tuck word-boundary swapd 
        [ ch>title ] [ ch>lower ] if ]
    map-case nip ;

: >case-fold ( string -- fold )
    >upper >lower ;

: insensitive= ( str1 str2 -- ? )
    [ >case-fold ] 2apply = ;

: lower? ( string -- ? )
    dup >lower = ;
: upper? ( string -- ? )
    dup >lower = ;
: title? ( string -- ? )
    dup >title = ;
: case-fold? ( string -- ? )
    dup >case-fold = ;
