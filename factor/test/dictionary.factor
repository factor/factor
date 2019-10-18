! Tests the dictionary words.

"Checking dictionary words." print

! Just make sure this works.

! OUTPUT          INPUT               WORD
[             ] [ "httpd"         ] [ apropos           ] test-word
[ t           ] [ "ifte"          ] [ worddef compound? ] test-word
[ t           ] [ "dup"           ] [ worddef shuffle?  ] test-word
[ f           ] [ "ifte"          ] [ worddef shuffle?  ] test-word
[ f           ] [ "dup"           ] [ worddef compound? ] test-word

! Test word internalization.

: gensym-test ( -- ? )
    f 10 [ gensym gensym = and ] times ;

[ f           ] [                 ] [ gensym-test       ] test-word

: intern-test ( 1 2 -- ? )
    [ intern ] 2apply = ;

[ f           ] [ "quux"          ] [ intern f =        ] test-word
[ t           ] [ "a" "a"         ] [ intern-test       ] test-word
[ f           ] [ "a" "A"         ] [ intern-test       ] test-word
[ f           ] [ "a" "B"         ] [ intern-test       ] test-word
[ f           ] [ "a" "a"      ] [ <word> swap intern = ] test-word

: worddef>list-test ( -- ? )
    [ dup * ] dup no-name worddef>list cdr = ;

[ t           ] [                 ] [ worddef>list-test ] test-word

: words-test ( -- ? )
    t words [ word? and ] each ;

[ t           ] [                 ] [ words-test        ] test-word

! At one time we had a bug in FactorShuffleDefinition.toList()
~<< test-shuffle-1 A r:B -- A r:B >>~

[ "[ test-shuffle-1 A r:B -- A r:B ]" ]
[ "test-shuffle-1" ]
[ worddef>list >str ]
test-word

~<< test-shuffle-2 A B -- r:A r:B >>~

[ "[ test-shuffle-2 A B -- r:A r:B ]" ]
[ "test-shuffle-2" ]
[ worddef>list >str ]
test-word

~<< test-shuffle-3 A r:B r:C r:D r:E -- A C D E >>~

[ "[ test-shuffle-3 A r:B r:C r:D r:E -- A C D E ]" ]
[ "test-shuffle-3" ]
[ worddef>list >str ]
test-word
