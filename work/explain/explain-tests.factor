! Copyright (C) 2011 rien
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays classes.singleton combinators continuations effects
kernel locals make math math.order multiline parser quotations
sequences sequences.generalizations stack-checker unicode.case ;

USING: tools.test explain ;
IN: explain.tests

! exec-word executes stack-shuffler words correctly

[ { "a" "x" "y" "z" "x" } ]
[ { "a" "x" "y" "z" } \ pick exec-word ]
unit-test

[ { "a" "y" "z" "x" } ]
[ { "a" "x" "y" "z" } \ rot exec-word ]
unit-test

[ { "a" "y" "x" "z" } ]
[ { "a" "x" "y" "z" } \ swapd exec-word ]
unit-test

[ { 1 "z" "z" } ]
[ { 1 2 [ 1 + ] [ 1 - ] } \ bi exec-word ]
unit-test

[ { "z" 2 } ]
[ { 1 2 [ 1 + ] } \ dip exec-word ]
unit-test

[ { 1 "z" 3 } ]
[ { 1 2 3 [ + ] } \ keep exec-word ]
unit-test

[ { "z" } ]
[ { 1 2 } \ + exec-word ]
unit-test


! gen-steps gets the last step right
! (run with \ . instead of \ last to see what it does)

[ { 4 5 "z" } ]
[ [ 4 5 10 [ 2 / ] [ 2 * ] bi * ] ( -- x x x ) gen-steps last ]
unit-test

[ { 8 "z" } ]
[ [ 8 3 2 [ dup 19 + ] dip + + ] ( -- x x ) gen-steps last ]
unit-test

[ { "n" } ]
[ [ 1 2 3 [ + ] keep 3array sum ] ( -- x ) gen-steps last ]
unit-test

[ { "unused" "z" } ]
[ [ "unused" 1 2 3 4 [ * ] [ + + + ] bi ] ( -- x x ) gen-steps last ]
unit-test
