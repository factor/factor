! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces math kernel sequences accessors fry circular
unicode.case unicode.categories locals ;

IN: html.parser.state

TUPLE: state-parser sequence n ;

: <state-parser> ( sequence -- state-parser )
    state-parser new
        swap >>sequence
        0 >>n ;

: (get-char) ( n state -- char/f )
    sequence>> ?nth ; inline

: get-char ( state -- char/f )
    [ n>> ] keep (get-char) ; inline

: get-next ( state -- char/f )
    [ n>> 1 + ] keep (get-char) ; inline

: next ( state -- state )
    [ 1 + ] change-n ; inline

: get+increment ( state -- char/f )
    [ get-char ] [ next drop ] bi ; inline

: state-parse ( sequence quot -- )
    [ <state-parser> ] dip call ; inline

:: skip-until ( state quot: ( obj -- ? ) -- )
    state get-char [
        quot call [ state next quot skip-until ] unless
    ] when* ; inline recursive

: state-parse-end? ( state -- ? ) get-next not ;

: take-until ( state quot: ( obj -- ? ) -- sequence/f )
    over state-parse-end? [
        2drop f
    ] [
        [ drop n>> ]
        [ skip-until ]
        [ drop [ n>> ] [ sequence>> ] bi ] 2tri subseq
    ] if ; inline

:: take-until-sequence ( state-parser sequence -- sequence' )
    sequence length <growing-circular> :> growing
    state-parser
    [
        growing push-growing-circular
        sequence growing sequence=
    ] take-until :> found
    found dup length
    growing length 1- - head
    state-parser next drop ;
    
: skip-whitespace ( state -- state )
    [ [ blank? not ] take-until drop ] keep ;

: take-rest ( state -- sequence )
    [ drop f ] take-until ; inline

: take-until-object ( state obj -- sequence )
    '[ _ = ] take-until ;
