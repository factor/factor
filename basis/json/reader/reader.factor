! Copyright (C) 2008 Peter Burns, 2009 Philipp Winkler
! See http://factorcode.org/license.txt for BSD license.

USING: arrays assocs combinators fry hashtables io
io.streams.string json kernel make math math.parser namespaces
prettyprint sequences strings vectors ;

IN: json.reader

<PRIVATE

: value ( char -- num char )
    1string " \t\r\n,:}]" read-until
    [ append string>number ] dip ;

DEFER: j-string%

: j-escape% ( -- )
    read1 {
        { CHAR: b [ 8 ] }
        { CHAR: f [ 12 ] }
        { CHAR: n [ CHAR: \n ] }
        { CHAR: r [ CHAR: \r ] }
        { CHAR: t [ CHAR: \t ] }
        { CHAR: u [ 4 read hex> ] }
        [ ]
    } case [ , j-string% ] when* ;

: j-string% ( -- )
    "\\\"" read-until [ % ] dip
    CHAR: \" = [ j-escape% ] unless ;

: j-string ( -- str )
    "\\\"" read-until CHAR: \" =
    [ [ % j-escape% ] "" make ] unless ;

: second-last ( seq -- second-last )
    [ length 2 - ] [ nth ] bi ; inline

ERROR: json-error ;

: check-length ( seq n -- seq )
    [ dup length ] [ >= ] bi* [ json-error ] unless ;

: v-over-push ( vec -- vec' )
    2 check-length dup [ pop ] [ last ] bi push ;

: v-pick-push ( vec -- vec' )
    3 check-length dup [ pop ] [ second-last ] bi push ;

: (close) ( accum -- accum' )
    dup last V{ } = not [ v-over-push ] when ;

: (close-array) ( accum -- accum' )
    (close) dup pop >array suffix! ;

: (close-hash) ( accum -- accum' )
    (close) dup dup [ pop ] bi@ swap zip >hashtable suffix! ;

: scan ( accum char -- accum )
    ! 2dup 1string swap . . ! Great for debug...
    {
        { CHAR: \" [ j-string suffix! ] }
        { CHAR: [  [ V{ } clone suffix! ] }
        { CHAR: ,  [ v-over-push ] }
        { CHAR: ]  [ (close-array) ] }
        { CHAR: {  [ 2 [ V{ } clone suffix! ] times ] }
        { CHAR: :  [ v-pick-push ] }
        { CHAR: }  [ (close-hash) ] }
        { CHAR: \s [ ] }
        { CHAR: \t [ ] }
        { CHAR: \r [ ] }
        { CHAR: \n [ ] }
        { CHAR: t  [ 3 read drop t suffix! ] }
        { CHAR: f  [ 4 read drop f suffix! ] }
        { CHAR: n  [ 3 read drop json-null suffix! ] }
        [ value [ suffix! ] dip [ scan ] when*  ]
    } case ;

PRIVATE>

: read-jsons ( -- objects )
    V{ } clone input-stream get
    '[ _ stream-read1 dup ] [ scan ] while drop ;

: json> ( string -- object )
    [ read-jsons first ] with-string-reader ;
