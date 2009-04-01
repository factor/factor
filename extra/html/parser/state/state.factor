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

: state-parser-nth ( n state -- char/f )
    sequence>> ?nth ; inline

: current ( state -- char/f )
    [ n>> ] keep state-parser-nth ; inline

: previous ( state -- char/f )
    [ n>> 1 - ] keep state-parser-nth ; inline

: peek-next ( state -- char/f )
    [ n>> 1 + ] keep state-parser-nth ; inline

: next ( state -- state )
    [ 1 + ] change-n ; inline

: get+increment ( state -- char/f )
    [ current ] [ next drop ] bi ; inline

:: skip-until ( state quot: ( obj -- ? ) -- )
    state current [
        state quot call [ state next quot skip-until ] unless
    ] when ; inline recursive

: state-parse-end? ( state -- ? ) peek-next not ;

: take-until ( state quot: ( obj -- ? ) -- sequence/f )
    over state-parse-end? [
        2drop f
    ] [
        [ drop n>> ]
        [ skip-until ]
        [ drop [ n>> ] [ sequence>> ] bi ] 2tri subseq
    ] if ; inline

: take-while ( state quot: ( obj -- ? ) -- sequence/f )
    [ not ] compose take-until ; inline

:: take-until-sequence ( state-parser sequence -- sequence' )
    sequence length <growing-circular> :> growing
    state-parser
    [
        current growing push-growing-circular
        sequence growing sequence=
    ] take-until :> found
    found dup length
    growing length 1- - head
    state-parser next drop ;
    
: skip-whitespace ( state -- state )
    [ [ current blank? not ] take-until drop ] keep ;

: take-rest ( state -- sequence )
    [ drop f ] take-until ; inline

: take-until-object ( state obj -- sequence )
    '[ current _ = ] take-until ;

: state-parse ( sequence quot -- )
    [ <state-parser> ] dip call ; inline
