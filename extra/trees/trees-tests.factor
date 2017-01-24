USING: accessors arrays assocs combinators kernel math
math.combinatorics math.ranges namespaces random sequences
sequences.product tools.test trees trees.private ;
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

CONSTANT: test-tree2 TREE{
        { 110 110 }
        { 114 114 }
        { 106 106 }
        { 108 108 }
        { 104 104 }
        { 112 112 }
        { 116 116 }
        { 118 118 }
        { 120 120 }
        { 102 102 }
        { 100 100 }
    }

: ?a,b? ( a b ? ? -- range )
    2array {
        { { t t } [ [a,b] ] }
        { { t f } [ [a,b) ] }
        { { f t } [ (a,b] ] }
        { { f f } [ (a,b) ] }
    } case ;

! subtree>alist
: test-tree2-subtree>alist ( a b ? ? -- subalist )
    ?a,b? >array [ even? ] filter [ dup 2array ] map ;

: subtree>alist ( from-key to-key tree start-inclusive? end-inclusive? -- alist )
    2array {
        { { t f } [ subtree>alist[) ] }
        { { f t } [ subtree>alist(] ] }
        { { t t } [ subtree>alist[] ] }
        { { f f } [ subtree>alist() ] }
    } case ;

99 121 [a,b] 2 all-combinations
{ t f } dup 2array <product-sequence> 2array
[ first2 [ first2 ] bi@
    {
        [ test-tree2-subtree>alist 1array ]
        [ [ [ test-tree2 ] 2dip subtree>alist ] 2curry 2curry unit-test ]
    } 4cleave
] product-each

{ { } } [ 100 120 TREE{ } clone subtree>alist[] ] unit-test
{ { } } [ 120 TREE{ } clone headtree>alist[] ] unit-test
{ { } } [ 100 TREE{ } clone tailtree>alist[] ] unit-test

{ { 100 102 104 106 108 110 112 114 } }
[ 114 test-tree2 headtree>alist[] keys ] unit-test
{ { 100 102 104 106 108 110 112 } }
[ 114 test-tree2 headtree>alist[) keys ] unit-test
{ { 106 108 110 112 114 116 118 120 } }
[ 106 test-tree2 tailtree>alist[] keys ] unit-test
{ { 108 110 112 114 116 118 120 } }
[ 106 test-tree2 tailtree>alist(] keys ] unit-test
