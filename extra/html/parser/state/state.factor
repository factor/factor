! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces math kernel sequences accessors fry circular
unicode.case unicode.categories locals combinators.short-circuit
make combinators ;

IN: html.parser.state

TUPLE: state-parser sequence n ;

: <state-parser> ( sequence -- state-parser )
    state-parser new
        swap >>sequence
        0 >>n ;

: offset  ( state-parser offset -- char/f )
    swap
    [ n>> + ] [ sequence>> ?nth ] bi ; inline

: current ( state-parser -- char/f ) 0 offset ; inline

: previous ( state-parser -- char/f ) -1 offset ; inline

: peek-next ( state-parser -- char/f ) 1 offset ; inline

: advance ( state-parser -- state-parser )
    [ 1 + ] change-n ; inline

: advance* ( state-parser -- )
    advance drop ; inline

: get+increment ( state-parser -- char/f )
    [ current ] [ advance drop ] bi ; inline

:: skip-until ( state-parser quot: ( obj -- ? ) -- )
    state-parser current [
        state-parser quot call [ state-parser advance quot skip-until ] unless
    ] when ; inline recursive

: state-parse-end? ( state-parser -- ? ) current not ;

: take-until ( state-parser quot: ( obj -- ? ) -- sequence/f )
    over state-parse-end? [
        2drop f
    ] [
        [ drop n>> ]
        [ skip-until ]
        [ drop [ n>> ] [ sequence>> ] bi ] 2tri subseq
    ] if ; inline

: take-while ( state-parser quot: ( obj -- ? ) -- sequence/f )
    [ not ] compose take-until ; inline

:: take-sequence ( state-parser sequence -- obj/f )
    state-parser [ n>> dup sequence length + ] [ sequence>> ] bi <slice>
    sequence sequence= [
        sequence
        state-parser [ sequence length + ] change-n drop
    ] [
        f
    ] if ;

:: take-until-sequence ( state-parser sequence -- sequence' )
    sequence length <growing-circular> :> growing
    state-parser
    [
        current growing push-growing-circular
        sequence growing sequence=
    ] take-until :> found
    found dup length
    growing length 1- - head
    state-parser advance drop ;
    
: skip-whitespace ( state-parser -- state-parser )
    [ [ current blank? not ] take-until drop ] keep ;

: take-rest ( state-parser -- sequence )
    [ drop f ] take-until ; inline

: take-until-object ( state-parser obj -- sequence )
    '[ current _ = ] take-until ;

: state-parse ( sequence quot -- )
    [ <state-parser> ] dip call ; inline

:: take-quoted-string ( state-parser escape-char quote-char -- string )
    state-parser n>> :> start-n
    state-parser advance
    [
        {
            [ { [ previous escape-char = ] [ current quote-char = ] } 1&& ]
            [ current quote-char = not ]
        } 1||
    ] take-while :> string
    state-parser current quote-char = [
        state-parser advance* string
    ] [
        start-n state-parser (>>n) f
    ] if ;

: (take-token) ( state-parser -- string )
    skip-whitespace [ current { [ blank? ] [ f = ] } 1|| ] take-until ;

:: take-token* ( state-parser escape-char quote-char -- string/f )
    state-parser skip-whitespace
    dup current {
        { quote-char [ escape-char quote-char take-quoted-string ] }
        { f [ drop f ] }
        [ drop (take-token) ]
    } case ;

: take-token ( state-parser -- string/f )
    CHAR: \ CHAR: " take-token* ;
