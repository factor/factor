IN: scratchpad
USE: combinators
USE: compiler
USE: continuations
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: random
USE: stack
USE: stdio
USE: strings
USE: test
USE: words

"Checking dictionary words." print

! OUTPUT          INPUT               WORD
[ t           ] [ "when"          ] [ worddef compound? ] test-word
[ t           ] [ "dup"           ] [ worddef shuffle?  ] test-word
[ f           ] [ "ifte"          ] [ worddef shuffle?  ] test-word
[ f           ] [ "dup"           ] [ worddef compound? ] test-word

! Test word internalization.

: gensym-test ( -- ? )
    f 10 [ gensym gensym = and ] times ;

[ f           ] [                 ] [ gensym-test       ] test-word

: intern-test ( 1 2 -- ? )
    swap intern swap intern = ;

[ f ] [ "#:a" "#:a" ] [ intern-test ] test-word
[ t ] [ "#:" "#:" ] [ intern-test ] test-word

: word-parameter-test ( -- ? )
    [ dup * ] dup no-name word-parameter = ;

[ t           ] [                 ] [ word-parameter-test ] test-word

: words-test ( -- ? )
    t vocabs [ words [ word? and ] each ] each ;

[ t           ] [                 ] [ words-test        ] test-word

! At one time we had a bug in FactorShuffleDefinition.toList()
~<< test-shuffle-1 A r:B -- A r:B >>~

[ [ "A" "r:B" "--" "A" "r:B" ] ]
[ "test-shuffle-1" ]
[ word-parameter ]
test-word

~<< test-shuffle-2 A B -- r:A r:B >>~

[ [ "A" "B" "--" "r:A" "r:B" ] ]
[ "test-shuffle-2" ]
[ word-parameter ]
test-word

~<< test-shuffle-3 A r:B r:C r:D r:E -- A C D E >>~

[ [ "A" "r:B" "r:C" "r:D" "r:E" "--" "A" "C" "D" "E" ] ]
[ "test-shuffle-3" ]
[ word-parameter ]
test-word

[ [ 2 1 0 0 ] ] [ [ = ] ] [ balance>list ] test-word

[ [ 1 1 0 0 ] ] [ [ class-of ] ] [ balance>list ] test-word

[ "java.lang.Integer"  ] [ 5   ] [ class-of ] test-word
[ "java.lang.Double"   ] [ 5.0 ] [ class-of ] test-word

[ [ 1 1 0 0 ] ] [ [ clone ] ] [ balance>list ] test-word

[ [ 1 1 0 0 ] ] [ [ comment? ] ] [ balance>list ] test-word

: doc-test ( -- ) ;

[ t ] [ "doc-test" ] [ intern word-parameter car comment? ] test-word

[ [ 2 1 0 0 ] ] [ [ is ] ] [ balance>list ] test-word
[ t ] [ "java.lang.Integer" ] [ 0 100 random-int swap is ] test-word
[ t ] [ "java.lang.Object" ] [ [ 5 ] swap is ] test-word
[ f ] [ "java.lang.Object" ] [ f swap is ] test-word

[ [ 5 1 0 0 ] ] [ [ >=< ] ] [ balance>list ] test-word

[ [ 1 0 0 0 ] ] [ [ exit* ] ] [ balance>list ] test-word

[ [ 0 1 0 0 ] ] [ [ millis ] ] [ balance>list ] test-word

[ [ 1 1 0 0 ] ] [ [ system-property ] ] [ balance>list ] test-word

: test-last ( -- )
    nop ;
word >str "last-word-test" set

[ "test-last" ] [ ] [ "last-word-test" get ] test-word
[ f ] [ 5 ] [ compound? ] test-word
[ f ] [ 5 ] [ compiled? ] test-word
[ f ] [ 5 ] [ shuffle?  ] test-word

! Make sure callstack only clones callframes, and not
! everything on the callstack.
[ ] [ ] [ f unit dup dup set-cdr >r callstack r> 2drop ] test-word

[ t ] [ "ifte" intern dup worddef word-of-worddef = ] unit-test
