IN: scratchpad
USE: arithmetic
USE: combinators
USE: continuations
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: stack
USE: stdio
USE: strings
USE: test
USE: vocabularies
USE: words

"Checking dictionary words." print

! Just make sure this works.

! OUTPUT          INPUT               WORD
[             ] [ "httpd"         ] [ apropos.          ] test-word
[ t           ] [ "when"          ] [ worddef compound? ] test-word
[ t           ] [ "dup"           ] [ worddef shuffle?  ] test-word
[ f           ] [ "ifte"          ] [ worddef shuffle?  ] test-word
[ f           ] [ "dup"           ] [ worddef compound? ] test-word

! Test word internalization.

: gensym-test ( -- ? )
    f 10 [ gensym gensym = and ] times ;

[ f           ] [                 ] [ gensym-test       ] test-word

: intern-test ( 1 2 -- ? )
    [ intern ] 2apply = ;

[ f ] [ "#:a" "#:a" ] [ intern-test ] test-word
[ t ] [ "#:" "#:" ] [ intern-test ] test-word

: worddef>list-test ( -- ? )
    [ dup * ] dup no-name worddef>list = ;

[ t           ] [                 ] [ worddef>list-test ] test-word

: words-test ( -- ? )
    t vocabs [ words [ word? and ] each ] each ;

[ t           ] [                 ] [ words-test        ] test-word

! At one time we had a bug in FactorShuffleDefinition.toList()
~<< test-shuffle-1 A r:B -- A r:B >>~

[ [ "A" "r:B" "--" "A" "r:B" ] ]
[ "test-shuffle-1" ]
[ worddef>list ]
test-word

~<< test-shuffle-2 A B -- r:A r:B >>~

[ [ "A" "B" "--" "r:A" "r:B" ] ]
[ "test-shuffle-2" ]
[ worddef>list ]
test-word

~<< test-shuffle-3 A r:B r:C r:D r:E -- A C D E >>~

[ [ "A" "r:B" "r:C" "r:D" "r:E" "--" "A" "C" "D" "E" ] ]
[ "test-shuffle-3" ]
[ worddef>list ]
test-word

"car" usages.
