USING: kernel tools.test trees trees.avl-tree math random sequences ;
IN: temporary

[ "key1" 0 "key2" 0 ] [ T{ avl-node T{ node f "key1" f f T{ avl-node T{ node f "key2" } 1 } } 2 } [ single-rotate ] go-left [ node-left dup node-key swap avl-node-balance ] keep dup node-key swap avl-node-balance ] unit-test
[ "key1" 0 "key2" 0 ] [ T{ avl-node T{ node f "key1" f f T{ avl-node T{ node f "key2" } 1 } } 2 } [ select-rotate ] go-left [ node-left dup node-key swap avl-node-balance ] keep dup node-key swap avl-node-balance ] unit-test
[ "key1" 0 "key2" 0 ] [ T{ avl-node T{ node f "key1" f T{ avl-node T{ node f "key2" } -1 } } -2 } [ single-rotate ] go-right [ node-right dup node-key swap avl-node-balance ] keep dup node-key swap avl-node-balance ] unit-test
[ "key1" 0 "key2" 0 ] [ T{ avl-node T{ node f "key1" f T{ avl-node T{ node f "key2" } -1 } } -2 } [ select-rotate ] go-right [ node-right dup node-key swap avl-node-balance ] keep dup node-key swap avl-node-balance ] unit-test
[ "key1" -1 "key2" 0 "key3" 0 ]
[ T{ avl-node T{ node f "key1" f f
        T{ avl-node T{ node f "key2" f
            T{ avl-node T{ node f "key3" } 1 } }
        -1 } }
    2 } [ double-rotate ] go-left
    [ node-left dup node-key swap avl-node-balance ] keep
    [ node-right dup node-key swap avl-node-balance ] keep
    dup node-key swap avl-node-balance ] unit-test
[ "key1" 0 "key2" 0 "key3" 0 ]
[ T{ avl-node T{ node f "key1" f f
        T{ avl-node T{ node f "key2" f
            T{ avl-node T{ node f "key3" } 0 } }
        -1 } }
    2 } [ double-rotate ] go-left
    [ node-left dup node-key swap avl-node-balance ] keep
    [ node-right dup node-key swap avl-node-balance ] keep
    dup node-key swap avl-node-balance ] unit-test
[ "key1" 0 "key2" 1 "key3" 0 ]
[ T{ avl-node T{ node f "key1" f f
        T{ avl-node T{ node f "key2" f
            T{ avl-node T{ node f "key3" } -1 } }
        -1 } }
    2 } [ double-rotate ] go-left
    [ node-left dup node-key swap avl-node-balance ] keep
    [ node-right dup node-key swap avl-node-balance ] keep
    dup node-key swap avl-node-balance ] unit-test

[ "key1" 1 "key2" 0 "key3" 0 ]
[ T{ avl-node T{ node f "key1" f
        T{ avl-node T{ node f "key2" f f
            T{ avl-node T{ node f "key3" } -1 } }
        1 } }
    -2 } [ double-rotate ] go-right
    [ node-right dup node-key swap avl-node-balance ] keep
    [ node-left dup node-key swap avl-node-balance ] keep
    dup node-key swap avl-node-balance ] unit-test
[ "key1" 0 "key2" 0 "key3" 0 ]
[ T{ avl-node T{ node f "key1" f
        T{ avl-node T{ node f "key2" f f
            T{ avl-node T{ node f "key3" } 0 } }
        1 } }
    -2 } [ double-rotate ] go-right
    [ node-right dup node-key swap avl-node-balance ] keep
    [ node-left dup node-key swap avl-node-balance ] keep
    dup node-key swap avl-node-balance ] unit-test
[ "key1" 0 "key2" -1 "key3" 0 ]
[ T{ avl-node T{ node f "key1" f
        T{ avl-node T{ node f "key2" f f
            T{ avl-node T{ node f "key3" } 1 } }
        1 } }
    -2 } [ double-rotate ] go-right
    [ node-right dup node-key swap avl-node-balance ] keep
    [ node-left dup node-key swap avl-node-balance ] keep
    dup node-key swap avl-node-balance ] unit-test

! random testing uncovered this little bugger
[ t t ] [ f "d" T{ avl-node
              T{ node f "e" f
                  T{ avl-node 
                      T{ node f "b" f
                          T{ avl-node T{ node f "a" } 0 }
                          T{ avl-node T{ node f "c" f } 0 }
                          0 }
                      0 }
                  T{ avl-node T{ node f "f" } 0 } }
              -1 } node-set dup valid-avl-node? nip swap valid-node? ] unit-test

[ "eight" ] [ <avl-tree> "seven" 7 pick tree-insert "eight" 8 pick tree-insert "nine" 9 pick tree-insert tree-root node-value ] unit-test
[ "another eight" ] [ <avl-tree> "seven" 7 pick tree-set "eight" 8 pick tree-set "another eight" 8 pick tree-set 8 swap tree-get ] unit-test
! [ <avl-tree> "seven" 7 pick tree-insert 
[ t t ] [ <avl-tree> 3 increasing-tree dup valid-avl-tree? swap valid-tree? ] unit-test
[ t t ] [ <avl-tree> 9 increasing-tree dup valid-avl-tree? swap valid-tree? ] unit-test ! fails when tree growth isn't terminated after a rebalance
[ t t ] [ <avl-tree> 10 increasing-tree dup valid-avl-tree? swap valid-tree? ] unit-test

[ t t ] [ <avl-tree> 3 decreasing-tree dup valid-avl-tree? swap valid-tree? ] unit-test
[ t t ] [ <avl-tree> 4 decreasing-tree dup valid-avl-tree? swap valid-tree? ] unit-test
[ t t ] [ <avl-tree> 5 decreasing-tree dup valid-avl-tree? swap valid-tree? ] unit-test
[ t t ] [ <avl-tree> 10 decreasing-tree dup valid-avl-tree? swap valid-tree? ] unit-test

[ t t ] [ <avl-tree> 5 random-tree dup valid-avl-tree? swap valid-tree? ] unit-test
[ t t ] [ <avl-tree> 19 random-tree dup valid-avl-tree? swap valid-tree? ] unit-test
[ t t ] [ <avl-tree> 30 random-tree dup valid-avl-tree? swap valid-tree? ] unit-test
[ t t ] [ <avl-tree> 82 random-tree dup valid-avl-tree? swap valid-tree? ] unit-test
[ t t ] [ <avl-tree> 100 random-tree dup valid-avl-tree? swap valid-tree? ] unit-test

! borrowed from tests/bst.factor
: test-tree ( -- tree )
    <avl-tree>
    "seven"          7 pick tree-insert
    "nine"           9 pick tree-insert
    "four"           4 pick tree-insert
    "another four"   4 pick tree-insert
    "replaced seven" 7 pick tree-set ;

! test tree-insert, tree-set, tree-get, tree-get*, and tree-get-all
[ "seven" ] [ <avl-tree> "seven" 7 pick tree-insert 7 swap tree-get ] unit-test
[ "seven" t ] [ <avl-tree> "seven" 7 pick tree-insert 7 swap tree-get* ] unit-test
[ f f ] [ <avl-tree> "seven" 7 pick tree-insert 8 swap tree-get* ] unit-test
[ "seven" ] [ <avl-tree> "seven" 7 pick tree-set 7 swap tree-get ] unit-test
[ "replacement" ] [ <avl-tree> "seven" 7 pick tree-insert "replacement" 7 pick tree-set 7 swap tree-get ] unit-test
[ "nine" ] [ test-tree 9 swap tree-get ] unit-test
[ t ] [ test-tree 4 swap tree-get-all { "another four" "four" } sequence= ] unit-test
[ t ] [ test-tree 11 swap tree-get-all empty? ] unit-test
[ t ] [ test-tree 7 swap tree-get-all { "replaced seven" } sequence= ] unit-test

! test tree-delete
[ f ] [ test-tree 9 over tree-delete 9 swap tree-get ] unit-test
[ "replaced seven" ] [ test-tree 9 over tree-delete 7 swap tree-get ] unit-test
[ f ] [ test-tree 4 over tree-delete-all 4 swap tree-get ] unit-test
[ "nine" ] [ test-tree 7 over tree-delete 4 over tree-delete 9 swap tree-get ] unit-test
[ "nine" ] [ test-tree 7 over tree-delete 4 over tree-delete-all 9 swap tree-get ] unit-test

: test-random-deletions ( tree -- ? )
    #! deletes one node at random from the tree, checking avl and tree
    #! properties after each deletion, until the tree is empty
    dup stump? [
        drop t
    ] [
        dup tree-keys random over tree-delete dup valid-avl-tree? over valid-tree? and [
            test-random-deletions
        ] [
            dup print-tree
        ] if
    ] if ;

[ t ] [ <avl-tree> 5 random-tree test-random-deletions ] unit-test
[ t ] [ <avl-tree> 30 random-tree test-random-deletions ] unit-test
[ t ] [ <avl-tree> 100 random-tree test-random-deletions ] unit-test

