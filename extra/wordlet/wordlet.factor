! Copyright (C) 2022 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs assocs.extras base91 colors
combinators hashtables io io.encodings.binary
io.encodings.string io.encodings.utf8 io.files io.styles kernel
literals math random ranges sequences sequences.extras sets
sorting splitting strings ;
IN: wordlet

<PRIVATE

CONSTANT: word-list $[
    "vocab:wordlet/word-list.txt" binary file-contents
    base91> utf8 decode "\n" split fast-set
]

PRIVATE>

TUPLE: wordlet-game secret-word chances guesses ;

: <wordlet-game> ( secret-word chances -- wordlet-game )
    wordlet-game new
        swap >>chances
        swap >>secret-word
        V{ } clone >>guesses ; inline

: guess>chars ( secret guess -- seq )
    [ zip [ first2 = not ] filter keys [ 1string ] map ] 2keep
    [
        [ nip 1string ] [ = ] 2bi
        [ COLOR: green ]
        [
            2dup swap member?
            [ [ swap remove-first ] [ COLOR: yellow ] bi ]
            [ COLOR: gray ] if
        ] if
        background associate 2array
    ] { } 2map-as nip ;

: color>n ( color -- n )
    {
        { COLOR: gray [ 1 ] }
        { COLOR: yellow [ 2 ] }
        { COLOR: green [ 3 ] }
    } case ;

: reamining-chars ( game -- chars )
    [ secret-word>> ] [ guesses>> ] bi [
       guess>chars
    ] with map concat members
    [ background of ] assoc-map
    [ first ] collect-value-by
    [ [ color>n ] zip-with sort-values reverse first first ] assoc-map
    CHAR: a CHAR: z [a..b] [ 1string COLOR: white ] { } map>assoc [ or ] assoc-merge ;

: print-remaining-chars ( game -- )
    reamining-chars [ background associate format ] assoc-each nl ;

: print-guesses ( game -- )
    [ secret-word>> ] [ guesses>> ] bi [
        guess>chars [ format ] assoc-each nl
    ] with each nl ;

: read-guess ( -- guess )
    "guess: " write
    readln >lower dup length 5 =
    [ " needs to have 5 letters" append print read-guess ] unless
    dup word-list in?
    [ " not in the word list" append print read-guess ] unless ;

: check-winner? ( game -- ? )
    [ secret-word>> ] [ guesses>> ?last ] bi = ;

: print-secret ( game color -- )
    [ secret-word>> ] [ background associate ] bi* format nl ;

: maybe-stop? ( game -- ? )
    [ guesses>> length ] [ chances>> ] bi >= ;

: play-wordlet ( game -- )
    dup maybe-stop? [
        COLOR: red print-secret
    ] [
        {
            [ print-guesses ]
            [ print-remaining-chars ]
            [ [ read-guess ] dip guesses>> push ]
            [
                dup check-winner?
                [ COLOR: green print-secret ]
                [ play-wordlet ] if
            ]
        } cleave
    ] if ;

: play-random-wordlet-game ( -- )
    "wordlet Started" print
    word-list random 6 <wordlet-game> play-wordlet ;

MAIN: play-random-wordlet-game
