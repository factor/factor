! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces math kernel sequences accessors fry circular
unicode.case unicode.categories locals ;
IN: html.parser.state

TUPLE: state-parser string i ;

: <state-parser> ( string -- state-parser )
    state-parser new
        swap >>string
        0 >>i ;

: (get-char) ( i state -- char/f )
    string>> ?nth ; inline

: get-char ( state -- char/f )
    [ i>> ] keep (get-char) ; inline

: get-next ( state -- char/f )
    [ i>> 1+ ] keep (get-char) ; inline

: next ( state -- state )
    [ 1+ ] change-i ; inline

: get+increment ( state -- char/f )
    [ get-char ] [ next drop ] bi ; inline

: string-parse ( string quot -- )
    [ <state-parser> ] dip call ; inline

:: skip-until ( state quot: ( obj -- ? ) -- )
    state get-char [
        quot call [ state next quot skip-until ] unless
    ] when* ; inline recursive

: take-until ( state quot: ( obj -- ? ) -- string )
    [ drop i>> ]
    [ skip-until ]
    [ drop [ i>> ] [ string>> ] bi ] 2tri subseq ; inline

:: take-until-string ( state-parser string -- string' )
    string length <growing-circular> :> growing
    state-parser
    [
        growing push-growing-circular
        string growing sequence=
    ] take-until :> found
    found dup length
    growing length 1- - head
    state-parser next drop ;
    
: skip-whitespace ( state -- state )
    [ [ blank? not ] take-until drop ] keep ;

: take-rest ( state -- string )
    [ drop f ] take-until ; inline

: take-until-char ( state ch -- string )
    '[ _ = ] take-until ;

: string-parse-end? ( state -- ? ) get-next not ;
