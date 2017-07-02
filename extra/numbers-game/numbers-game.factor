USING: kernel math math.parser random io ;
IN: numbers-game

: printfl ( s -- )
    print flush ;

: writefl ( s -- )
    write flush ;

: read-number ( -- n )
    readln string>number ;

: guess-banner ( -- )
    "I'm thinking of a number between 0 and 100." printfl ;

: guess-prompt ( -- ) "Enter your guess: " writefl ;

: too-high ( -- ) "Too high" printfl ;

: too-low ( -- ) "Too low" printfl ;

: correct ( -- ) "Correct - you win!" printfl ;

: inexact-guess ( actual guess -- )
     < [ too-high ] [ too-low ] if ;

: judge-guess ( actual guess -- ? )
    2dup = [ 2drop correct f ] [ inexact-guess t ] if ;

: number-to-guess ( -- n ) 100 random ;

: numbers-game-loop ( actual -- )
    dup guess-prompt read-number judge-guess
    [ numbers-game-loop ] [ drop ] if ;

: numbers-game ( -- )
    guess-banner number-to-guess numbers-game-loop ;

MAIN: numbers-game
