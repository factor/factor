IN: scratchpad
USE: math
USE: test
USE: words
USE: namespaces
USE: logic
USE: lists

[ 4 ] [
    "poo" "scratchpad" create [ 2 2 + ] define-compound
    "poo" [ "scratchpad" ] search execute
] unit-test

: words-test ( -- ? )
    t vocabs [ words [ word? and ] each ] each ;

[ t           ] [                 ] [ words-test        ] test-word


: test-last ( -- ) ;
word word-name "last-word-test" set

[ "test-last" ] [ ] [ "last-word-test" get ] test-word
[ f ] [ 5 ] [ compound? ] test-word
