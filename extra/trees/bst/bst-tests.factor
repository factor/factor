USING: trees trees.bst tools.test kernel sequences ;
IN: temporary

: test-tree ( -- tree )
    <bst>
    "seven"          7 pick tree-insert
    "nine"           9 pick tree-insert
    "four"           4 pick tree-insert
    "another four"   4 pick tree-insert
    "replaced seven" 7 pick tree-set ;

! test tree-insert, tree-set, tree-get, tree-get*, and tree-get-all
[ "seven" ] [ <bst> "seven" 7 pick tree-insert 7 swap tree-get ] unit-test
[ "seven" t ] [ <bst> "seven" 7 pick tree-insert 7 swap tree-get* ] unit-test
[ f f ] [ <bst> "seven" 7 pick tree-insert 8 swap tree-get* ] unit-test
[ "seven" ] [ <bst> "seven" 7 pick tree-set 7 swap tree-get ] unit-test
[ "replacement" ] [ <bst> "seven" 7 pick tree-insert "replacement" 7 pick tree-set 7 swap tree-get ] unit-test
[ "four" ] [ test-tree 4 swap tree-get ] unit-test
[ "nine" ] [ test-tree 9 swap tree-get ] unit-test
[ t ] [ test-tree 4 swap tree-get-all { "another four" "four" } sequence= ] unit-test
[ t ] [ test-tree 11 swap tree-get-all empty? ] unit-test
[ t ] [ test-tree 7 swap tree-get-all { "replaced seven" } sequence= ] unit-test

! test tree-delete
[ f ] [ test-tree 9 over tree-delete 9 swap tree-get ] unit-test
[ "replaced seven" ] [ test-tree 9 over tree-delete 7 swap tree-get ] unit-test
[ "four" ] [ test-tree 9 over tree-delete 4 swap tree-get ] unit-test
! TODO: sometimes this shows up as "another four" because of randomisation
! [ "nine" "four" ] [ test-tree 7 over tree-delete 9 over tree-get 4 rot tree-get ] unit-test
! [ "another four" ] [ test-tree 4 over tree-delete 4 swap tree-get ] unit-test
[ f ] [ test-tree 4 over tree-delete-all 4 swap tree-get ] unit-test
[ "nine" ] [ test-tree 7 over tree-delete 4 over tree-delete 9 swap tree-get ] unit-test
[ "nine" ] [ test-tree 7 over tree-delete 4 over tree-delete-all 9 swap tree-get ] unit-test

! test valid-node?
[ t ] [ T{ node f 0 } valid-node? ] unit-test
[ t ] [ T{ node f 0 f T{ node f -1 } } valid-node? ] unit-test
[ t ] [ T{ node f 0 f f T{ node f 1 } } valid-node? ] unit-test
[ t ] [ T{ node f 0 f T{ node f -1 } T{ node f 1 } } valid-node? ] unit-test
[ f ] [ T{ node f 0 f T{ node f 1 } } valid-node? ] unit-test
[ f ] [ T{ node f 0 f f T{ node f -1 } } valid-node? ] unit-test

! random testing
[ t ] [ <bst> 10 random-tree valid-tree? ] unit-test

