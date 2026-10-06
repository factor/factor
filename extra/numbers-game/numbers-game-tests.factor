USING: io.streams.string numbers-game tools.test ;
IN: numbers-game.tests

{ "Enter your guess: " } [
    [ "" [ 42 numbers-game-loop ] with-string-reader ] with-string-writer
] unit-test

{ "Enter your guess: Please enter a number.\nEnter your guess: Too low\nEnter your guess: Too high\nEnter your guess: Correct - you win!\n" } [
    [ "bad\n20\n60\n42\n" [ 42 numbers-game-loop ] with-string-reader ] with-string-writer
] unit-test
