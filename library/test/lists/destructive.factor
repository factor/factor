IN: scratchpad
USE: lists
USE: namespaces
USE: stack
USE: test

[ "a" | "b" ] clone-list "x" set
[ [ 1 | "b" ] ] [ 1 "x" get set-car "x" get ] unit-test

[ "a" | "b" ] clone-list "x" set
[ [ "a" | 2 ] ] [ 2 "x" get set-cdr "x" get ] unit-test

: clone-and-nappend ( list list -- list )
    swap clone-list swap clone-list nappend ;

[ [ ]         ] [ [ ]   [ ]       clone-and-nappend ] unit-test
[ [ 1 ]       ] [ [ 1 ] [ ]       clone-and-nappend ] unit-test
[ [ 2 ]       ] [ [ ] [ 2 ]       clone-and-nappend ] unit-test
[ [ 1 2 3 4 ] ] [ [ 1 2 3 ] [ 4 ] clone-and-nappend ] unit-test

: clone-and-nreverse ( list -- list )
    clone-list nreverse ;

[ [ ]       ] [ [ ]       clone-and-nreverse ] unit-test
[ [ 1 ]     ] [ [ 1 ]     clone-and-nreverse ] unit-test
[ [ 3 2 1 ] ] [ [ 1 2 3 ] clone-and-nreverse ] unit-test

[ 1 2 3 ] clone-list "x" set [ 4 5 6 ] clone-list "y" set

[ [ 4 5 6 ] ] [ "x" get "y" get nappend drop "y" get ] unit-test

[ 1 2 3 ] clone-list "x" set [ 4 5 6 ] clone-list "y" set

[ [ 1 2 3 4 5 6 ] ] [ "x" get "y" get ] [ nappend drop "x" get ] test-word
