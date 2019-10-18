IN: scratchpad
USE: arithmetic
USE: combinators
USE: compiler
USE: errors
USE: inspector
USE: kernel
USE: lists
USE: logic
USE: namespaces
USE: random
USE: stack
USE: stdio
USE: strings
USE: test
USE: words
USE: vocabularies

"Miscellaneous tests." print

[ [ 2 1 0 0 ] ] [ [ = ] ] [ balance>list ] test-word

[ [ 1 1 0 0 ] ] [ [ class-of ] ] [ balance>list ] test-word

[ "java.lang.Integer"  ] [ 5   ] [ class-of ] test-word
[ "java.lang.Double"   ] [ 5.0 ] [ class-of ] test-word

[ [ 1 1 0 0 ] ] [ [ clone ] ] [ balance>list ] test-word

[ [ 1 1 0 0 ] ] [ [ clone-array ] ] [ balance>list ] test-word

[ [ 1 1 0 0 ] ] [ [ comment? ] ] [ balance>list ] test-word

: doc-test ( -- ) ;

[ t ] [ "doc-test" ] [ intern worddef>list car comment? ] test-word

[ [ 1 1 0 0 ] ] [ [ deep-clone-array ] ] [ balance>list ] test-word

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

[ t ] [ ] [
    [ "global" "vocabularies" "test" "test-word" ] object-path
    "test-word" [ "test" ] search eq?
] test-word

! Make sure callstack only clones callframes, and not
! everything on the callstack.
[ ] [ ] [ f unit dup dup rplacd >r callstack r> 2drop ] test-word

"Miscellaneous passed." print
