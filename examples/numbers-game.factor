! Numbers game example

IN: numbers-game
USING: kernel math parser random stdio ;

: read-number ( -- n ) read parse-number ;

: guess-banner
    "I'm thinking of a number between 0 and 100." print ;
: guess-prompt "Enter your guess: " write ;
: too-high "Too high" print ;
: too-low "Too low" print ;
: correct "Correct - you win!" print ;

: inexact-guess ( actual guess -- )
     < [ too-high ] [ too-low ] ifte ;

: judge-guess ( actual guess -- ? )
    2dup = [
        2drop correct f
    ] [
        inexact-guess t
    ] ifte ;

: number-to-guess ( -- n ) 0 100 random-int ;

: numbers-game-loop ( actual -- )
    dup guess-prompt read-number judge-guess [
        numbers-game-loop
    ] [
        drop
    ] ifte ;

: numbers-game number-to-guess numbers-game-loop ;
