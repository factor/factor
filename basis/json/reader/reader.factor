! Copyright (C) 2008 Peter Burns, 2009 Philipp Winkler
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs combinators fry hashtables io
io.streams.string json kernel kernel.private make math
math.parser namespaces prettyprint sequences sequences.private
strings vectors ;

IN: json.reader

<PRIVATE

: value ( char stream -- num char )
    [ 1string ] [ " \t\r\n,:}]" swap stream-read-until ] bi*
    [ append string>number ] dip ;

DEFER: j-string%

: j-escape% ( stream -- )
    dup stream-read1 {
        { CHAR: b [ 8 ] }
        { CHAR: f [ 12 ] }
        { CHAR: n [ CHAR: \n ] }
        { CHAR: r [ CHAR: \r ] }
        { CHAR: t [ CHAR: \t ] }
        { CHAR: u [ 4 over stream-read hex> ] }
        [ ]
    } case [ , j-string% ] [ drop ] if* ;

: j-string% ( stream -- )
    "\\\"" over stream-read-until [ % ] dip
    CHAR: \" = [ drop ] [ j-escape% ] if ;

: j-string ( stream -- str )
    "\\\"" over stream-read-until CHAR: \" =
    [ nip ] [ [ % j-escape% ] "" make ] if ;

: second-last-unsafe ( seq -- second-last )
    [ length 2 - ] [ nth-unsafe ] bi ; inline

: pop-unsafe ( seq -- elt )
    [ length 1 - ] keep [ nth-unsafe ] [ shorten ] 2bi ; inline

ERROR: json-error ;

: check-length ( seq n -- seq )
    [ dup length ] [ >= ] bi* [ json-error ] unless
    { vector } declare ; inline

: v-over-push ( vec -- vec' )
    2 check-length dup [ pop-unsafe ] [ last-unsafe ] bi
    push ;

: v-pick-push ( vec -- vec' )
    3 check-length dup [ pop-unsafe ] [ second-last-unsafe ] bi
    push ;

: (close) ( accum -- accum' )
    { vector } declare
    dup last V{ } = not [ v-over-push ] when ;

: (close-array) ( accum -- accum' )
    { vector } declare
    (close) dup pop >array suffix! ;

: (close-hash) ( accum -- accum' )
    { vector } declare
    (close) dup dup [ pop ] bi@ 2dup min-length <hashtable>
    [ [ set-at ] curry 2each ] keep suffix! ;

: scan ( stream accum char -- stream accum )
    ! 2dup 1string swap . . ! Great for debug...
    {
        { CHAR: \" [ over j-string suffix! ] }
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
        { CHAR: t  [ 3 pick stream-read drop t suffix! ] }
        { CHAR: f  [ 4 pick stream-read drop f suffix! ] }
        { CHAR: n  [ 3 pick stream-read drop json-null suffix! ] }
        [ pick value [ suffix! ] dip [ scan ] when*  ]
    } case ;

: stream-json-read ( stream -- objects )
    V{ } clone over '[ _ stream-read1 dup ]
    [ scan ] while drop nip ;

PRIVATE>

: read-jsons ( -- objects )
    input-stream get stream-json-read ;

: json> ( string -- object )
    [ read-jsons first ] with-string-reader ;
