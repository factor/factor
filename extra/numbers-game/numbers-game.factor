USING: combinators io kernel math.order math.parser random ;
IN: numbers-game

: guess-banner ( -- )
    "I'm thinking of a number between 0 and 100." print flush ;

: guess-number ( -- n )
    "Enter your guess: " write flush readln string>number ;

: correct? ( actual guess -- ? )
    <=> {
        { +lt+ [ "Too high" print flush f ] }
        { +eq+ [ "Correct - you win!" print flush t ] }
        { +gt+ [ "Too low" print flush f ] }
    } case ;

: numbers-game-loop ( actual -- )
    [ dup guess-number correct? not ] loop drop ;

: numbers-game ( -- )
    guess-banner 100 random numbers-game-loop ;

MAIN: numbers-game
