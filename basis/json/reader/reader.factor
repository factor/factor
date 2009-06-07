! Copyright (C) 2008 Peter Burns, 2009 Philipp Winkler
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators io io.streams.string json
kernel math math.parser math.parser.private prettyprint
sequences strings vectors ;
IN: json.reader

<PRIVATE
: value ( char -- num char )
    1string " \t\r\n,:}]" read-until
    [
        append
        [ string>float ]
        [ [ "eE." index ] any? [ >integer ] unless ] bi
    ] dip ;

DEFER: j-string
    
: convert-string ( str -- str )
    read1
    {
        { CHAR: b [ 8 ] }
        { CHAR: f [ 12 ] }
        { CHAR: n [ CHAR: \n ] }
        { CHAR: r [ CHAR: \r ] }
        { CHAR: t [ CHAR: \t ] }
        { CHAR: u [ 4 read hex> ] }
        [ ]
    } case
    dup
    [ 1string append j-string append ]
    [ drop ] if ;
    
: j-string ( -- str )
    "\\\"" read-until CHAR: \" =
    [ convert-string ] unless ;
    
: second-last ( seq -- second-last )
    [ length 2 - ] keep nth ; inline

: third-last ( seq -- third-last )
    [ length 3 - ] keep nth ; inline
    
: last2 ( seq -- second-last last )
    [ second-last ] [ last ] bi ; inline

: last3 ( seq -- third-last second-last last )
    [ third-last ] [ last2 ] bi ; inline

: v-over-push ( vec -- vec' )
    dup length 2 >=
    [
        dup
        [ pop ]
        [ last ] bi push
    ] when ;

: v-pick-push ( vec -- vec' )
    dup length 3 >=
    [
        dup
        [ pop ]
        [ second-last ] bi push
    ] when ;

: (close-array) ( accum -- accum' )
    dup last vector? [ v-over-push ] unless
    dup pop >array over push ;

: (close-hash) ( accum -- accum' )
    dup length 3 >= [ v-over-push ] when
    dup dup [ pop ] dip pop swap
    zip H{ } assoc-clone-like over push ;
                                                 
: scan ( accum char -- accum )
    ! 2dup . . ! Great for debug...
    [
        {
            { CHAR: \" [ j-string over push ] }
            { CHAR: [  [ V{ } clone over push ] }
            { CHAR: ,  [ v-over-push ] }
            { CHAR: ]  [ (close-array) ] }
            { CHAR: {  [ 2 [ V{ } clone over push ] times ] }
            { CHAR: :  [ v-pick-push ] }
            { CHAR: }  [ (close-hash) ] }
            { CHAR: \u000020 [ ] }
            { CHAR: \t [ ] }
            { CHAR: \r [ ] }
            { CHAR: \n [ ] }
            { CHAR: t  [ 3 read drop t over push ] }
            { CHAR: f  [ 4 read drop f over push ] }
            { CHAR: n  [ 3 read drop json-null over push ] }
            [ value [ over push ] dip [ scan ] when*  ]
        } case 
    ] when* ;

: (json-parser>) ( string -- object )
    [ V{ } clone [ read1 dup ] [ scan ] while drop first ] with-string-reader ;
    
PRIVATE>
    
: json> ( string -- object )
    (json-parser>) ;