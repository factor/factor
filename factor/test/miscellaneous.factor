! Miscellaneous tests.

"Miscellaneous tests." print

[ [ 2 1 0 0 ] ] [ [ = ] ] [ balance>list ] test-word

[ [ 1 1 0 0 ] ] [ [ class-of ] ] [ balance>list ] test-word

[ "java.lang.Integer"  ] [ 5   ] [ class-of ] test-word
[ "java.lang.Float"    ] [ 5.0 ] [ class-of ] test-word

[ [ 1 1 0 0 ] ] [ [ clone ] ] [ balance>list ] test-word

[ [ 1 1 0 0 ] ] [ [ cloneArray ] ] [ balance>list ] test-word

[ [ 1 1 0 0 ] ] [ [ comment? ] ] [ balance>list ] test-word

: doc-test ( -- ) ;

[ t ] [ "doc-test" ] [ worddef>list cdr car comment? ] test-word

[ [ 1 1 0 0 ] ] [ [ deepCloneArray ] ] [ balance>list ] test-word

[ [ 2 1 0 0 ] ] [ [ is ] ] [ balance>list ] test-word
[ t ] [ "java.lang.Integer" ] [ 0 100 random-int swap is ] test-word
[ t ] [ "java.lang.Object" ] [ [ a ] swap is ] test-word
[ f ] [ "java.lang.Object" ] [ f swap is ] test-word

[ [ 2 1 0 0 ] ] [ [ not= ] ] [ balance>list ] test-word

[ [ 4 1 0 0 ] ] [ [ 2= ] ] [ balance>list ] test-word

[ [ 5 1 0 0 ] ] [ [ >=< ] ] [ balance>list ] test-word

[ [ 1 0 0 0 ] ] [ [ error ] ] [ balance>list ] test-word

[ [ 1 0 0 0 ] ] [ [ exit* ] ] [ balance>list ] test-word

[ [ 0 1 0 0 ] ] [ [ millis ] ] [ balance>list ] test-word

[ [ 1 1 0 0 ] ] [ [ system-property ] ] [ balance>list ] test-word

: test-last ( -- )
    nop ;
word >str @last-word-test

[ "test-last" ] [ ] [ $last-word-test ] test-word
[ f ] [ 5 ] [ compound? ] test-word
[ f ] [ 5 ] [ compiled? ] test-word
[ f ] [ 5 ] [ shuffle?  ] test-word

[ t ] [ ] [
    [ "global" "dict" "test-word" "def" ] object-path
    #=test-word worddef =
] test-word

! Make sure callstack$ only clones callframes, and not
! everything on the callstack.
[ ] [ ] [ f unit dup dup rplacd >r callstack$ r> 2drop ] test-word

"Miscellaneous passed." print
