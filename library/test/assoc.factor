IN: scratchpad
USE: arithmetic
USE: combinators
USE: compiler
USE: hashtables
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: stack
USE: stdio
USE: strings
USE: test

"Checking association lists" print

[
    [ "monkey" | 1       ]
    [ "banana" | 2       ]
    [ "Java"   | 3       ]
    [ t        | "true"  ]
    [ f        | "false" ]
    [ [ 1 2 ]  | [ 2 1 ] ]
] "assoc" set

[ [ 1 1 0 0 ] ] [ [ assoc? ] ] [ balance>list ] test-word
[ t ] [ "assoc" get ] [ assoc? ] test-word
[ f ] [ [ 1 2 3 | 4 ] ] [ assoc? ] test-word

[ [ 2 1 0 0 ] ] [ [ assoc ] ] [ balance>list ] test-word
[ f           ] [ "monkey" f      ] [ assoc             ] test-word
[ f           ] [ "donkey" "assoc" get ] [ assoc             ] test-word
[ 1           ] [ "monkey" "assoc" get ] [ assoc             ] test-word
[ "false"     ] [ f        "assoc" get ] [ assoc             ] test-word
[ [ 2 1 ]     ] [ [ 1 2 ]  "assoc" get ] [ assoc             ] test-word

"is great" "Java" "assoc" get set-assoc "assoc" set

[ "is great" ] [ "Java" "assoc" get ] [ assoc ] test-word
