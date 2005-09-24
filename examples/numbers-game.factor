IN: numbers-game
USING: kernel math parser random io ;

: read-number ( -- n ) readln string>number ;

: guess-banner
    "I'm thinking of a number between 0 and 100." print ;
: guess-prompt "Enter your guess: " write ;
: too-high "Too high" print ;
: too-low "Too low" print ;
: correct "Correct - you win!" print ;

: inexact-guess ( actual guess -- )
     < [ too-high ] [ too-low ] if ;

: judge-guess ( actual guess -- ? )
    2dup = [ 2drop correct f ] [ inexact-guess t ] if ;

: number-to-guess ( -- n ) 0 100 random-int ;

: numbers-game-loop ( actual -- )
    dup guess-prompt read-number judge-guess
    [ numbers-game-loop ] [ drop ] if ;

: numbers-game number-to-guess numbers-game-loop ;
