USING: kernel tools.test trees trees.avl math random sequences assocs ;
IN: temporary

[ "key1" 0 "key2" 0 ] [
    T{ avl-node T{ node f "key1" f f T{ avl-node T{ node f "key2" } 1 } } 2 }
    [ single-rotate ] go-left
    [ node-left dup node-key swap avl-node-balance ] keep
    dup node-key swap avl-node-balance
] unit-test

[ "key1" 0 "key2" 0 ] [
    T{ avl-node T{ node f "key1" f f T{ avl-node T{ node f "key2" } 1 } } 2 }
    [ select-rotate ] go-left
    [ node-left dup node-key swap avl-node-balance ] keep
    dup node-key swap avl-node-balance
] unit-test

[ "key1" 0 "key2" 0 ] [
    T{ avl-node T{ node f "key1" f T{ avl-node T{ node f "key2" } -1 } } -2 }
    [ single-rotate ] go-right
    [ node-right dup node-key swap avl-node-balance ] keep
    dup node-key swap avl-node-balance
] unit-test

[ "key1" 0 "key2" 0 ] [
    T{ avl-node T{ node f "key1" f T{ avl-node T{ node f "key2" } -1 } } -2 }
    [ select-rotate ] go-right
    [ node-right dup node-key swap avl-node-balance ] keep
    dup node-key swap avl-node-balance
] unit-test

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

[ "eight" ] [
    <avl> "seven" 7 pick set-at
    "eight" 8 pick set-at "nine" 9 pick set-at
    tree-root node-value
] unit-test

[ "another eight" ] [
    <avl> "seven" 7 pick set-at
    "another eight" 8 pick set-at 8 swap at
] unit-test

! borrowed from tests/bst.factor
: test-tree ( -- tree )
    <avl>
    "seven"          7 pick set-at
    "nine"           9 pick set-at
    "four"           4 pick set-at
    "replaced four"  4 pick set-at
    "replaced seven" 7 pick set-at ;

! test set-at, at, at*
[ "seven" ] [ <avl> "seven" 7 pick set-at 7 swap at ] unit-test
[ "seven" t ] [ <avl> "seven" 7 pick set-at 7 swap at* ] unit-test
[ f f ] [ <avl> "seven" 7 pick set-at 8 swap at* ] unit-test
[ "seven" ] [ <avl> "seven" 7 pick set-at 7 swap at ] unit-test
[ "replacement" ] [ <avl> "seven" 7 pick set-at "replacement" 7 pick set-at 7 swap at ] unit-test
[ "nine" ] [ test-tree 9 swap at ] unit-test
[ "replaced four" ] [ test-tree 4 swap at ] unit-test
[ "replaced seven" ] [ test-tree 7 swap at ] unit-test

! test delete-at
[ f ] [ test-tree 9 over delete-at 9 swap at ] unit-test
[ "replaced seven" ] [ test-tree 9 over delete-at 7 swap at ] unit-test
[ "nine" ] [ test-tree 7 over delete-at 4 over delete-at 9 swap at ] unit-test
