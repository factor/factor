USING: accessors assocs kernel namespaces random tools.test
trees trees.private ;
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
{ "seven" } [ <tree> "seven" 7 pick set-at 7 of ] unit-test
{ "seven" t } [ <tree> "seven" 7 pick set-at 7 ?of ] unit-test
{ 8 f } [ <tree> "seven" 7 pick set-at 8 ?of ] unit-test
{ "seven" } [ <tree> "seven" 7 pick set-at 7 of ] unit-test
{ "replacement" } [ <tree> "seven" 7 pick set-at "replacement" 7 pick set-at 7 of ] unit-test
{ "replaced four" } [ test-tree 4 of ] unit-test
{ "nine" } [ test-tree 9 of ] unit-test

! test delete-at
{ f } [ test-tree 9 over delete-at 9 of ] unit-test
{ "replaced seven" } [ test-tree 9 over delete-at 7 of ] unit-test
{ "replaced four" } [ test-tree 9 over delete-at 4 of ] unit-test
{ "nine" "replaced four" } [ test-tree 7 over delete-at 9 over at 4 rot at ] unit-test
{ "nine" } [ test-tree 7 over delete-at 4 over delete-at 9 of ] unit-test

! test that cloning doesn't reshape the tree
{ TREE{
    { 7 "seven" }
    { 9 "nine" }
    { 4 "four" }
} } [ TREE{
    { 7 "seven" }
    { 9 "nine" }
    { 4 "four" }
} clone ] unit-test

! test height
{ 0 } [ TREE{ } height ] unit-test

{ 2 } [ TREE{
    { 7 "seven" }
    { 9 "nine" }
    { 4 "four" }
} height ] unit-test

{ 3 } [ TREE{
    { 9 "seven" }
    { 7 "nine" }
    { 4 "four" }
} height ] unit-test

! test assoc-size
{ 3 } [ test-tree assoc-size ] unit-test
{ 2 } [ test-tree 9 over delete-at assoc-size ] unit-test

TUPLE: constant-random pattern ;
M: constant-random random-32* pattern>> ;
{ T{ tree
    { root
        T{ node
            { key 2 }
            { value 2 }
            { left  T{ node { key 0 } { value 0 } } }
            { right T{ node { key 3 } { value 3 } } }
        }
    } { count 3 } }
} [
    TREE{ { 1 1 } { 3 3 } { 2 2 } { 0 0 } } clone
    T{ constant-random f 0xffffffff } random-generator [
        1 over delete-at
    ] with-variable
] unit-test
