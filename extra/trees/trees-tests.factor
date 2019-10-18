USING: trees assocs tools.test kernel sequences ;
IN: trees.tests

: test-tree ( -- tree )
    TREE{
        { 7 "seven" }
        { 9 "nine" }
        { 4 "four" } 
        { 4 "replaced four" } 
        { 7 "replaced seven" }
    } clone ;

! test set-at, at, at*
[ "seven" ] [ <tree> "seven" 7 pick set-at 7 swap at ] unit-test
[ "seven" t ] [ <tree> "seven" 7 pick set-at 7 swap at* ] unit-test
[ f f ] [ <tree> "seven" 7 pick set-at 8 swap at* ] unit-test
[ "seven" ] [ <tree> "seven" 7 pick set-at 7 swap at ] unit-test
[ "replacement" ] [ <tree> "seven" 7 pick set-at "replacement" 7 pick set-at 7 swap at ] unit-test
[ "replaced four" ] [ test-tree 4 swap at ] unit-test
[ "nine" ] [ test-tree 9 swap at ] unit-test

! test delete-at
[ f ] [ test-tree 9 over delete-at 9 swap at ] unit-test
[ "replaced seven" ] [ test-tree 9 over delete-at 7 swap at ] unit-test
[ "replaced four" ] [ test-tree 9 over delete-at 4 swap at ] unit-test
[ "nine" "replaced four" ] [ test-tree 7 over delete-at 9 over at 4 rot at ] unit-test
[ "nine" ] [ test-tree 7 over delete-at 4 over delete-at 9 swap at ] unit-test
