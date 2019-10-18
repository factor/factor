! Random tests

"Checking random number generation." print

[
    [ 10 , t ]
    [ 20 , f ]
    [ 30 , "monkey" ]
] @random-pairs

[ f ] [ $random-pairs ] [ random-element* [ t f "monkey" ] contains not ] test-word

"Random number checks complete." print
