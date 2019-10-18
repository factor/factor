IN: scratchpad
USE: compiler
USE: test
USE: stack
USE: words
USE: combinators
USE: lists

! Make sure that stack ops compile to correct code.
: compile-call ( quot -- word )
    gensym [ swap define-compound ] keep dup compile execute ;

[ ] [ 1 [ drop ] compile-call ] unit-test
[ ] [ [ 1 drop ] compile-call ] unit-test
[ ] [ [ 1 2 2drop ] compile-call ] unit-test
[ ] [ 1 [ 2 2drop ] compile-call ] unit-test
[ ] [ 1 2 [ 2drop ] compile-call ] unit-test
[ 1 1 ] [ 1 [ dup ] compile-call ] unit-test
[ 1 1 ] [ [ 1 dup ] compile-call ] unit-test
