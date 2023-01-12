USING: accessors arrays assocs combinators fry kernel locals
math math.combinatorics ranges namespaces random sequences
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

! test that converting from any tree to a basic tree doesn't reshape
! the tree
{ TREE{
    { 7 "seven" }
    { 9 "nine" }
    { 4 "four" }
} } [ TREE{
    { 7 "seven" }
    { 9 "nine" }
    { 4 "four" }
} >tree ] unit-test

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

: test-tree2-lower-key ( key -- key' )
    dup 2 mod 2 swap - - ;
: test-tree2-higher-key ( key -- key' )
    dup 2 mod 2 swap - + ;
: test-tree2-floor-key ( key -- key' )
    dup 2 mod - ;
: test-tree2-ceiling-key ( key -- key' )
    dup 2 mod + ;

{ f } [ 99 test-tree2 lower-node ]  unit-test
{ f } [ 100 test-tree2 lower-node ]  unit-test
100 121 (a..b] [
    [ test-tree2-lower-key 1array ] keep [ test-tree2 lower-node key>> ] curry unit-test
] each

99 120 [a..b) [
    [ test-tree2-higher-key 1array ] keep [ test-tree2 higher-node key>> ] curry unit-test
] each
{ f } [ 120 test-tree2 higher-node ]  unit-test
{ f } [ 121 test-tree2 higher-node ]  unit-test

{ f } [ 99 test-tree2 floor-node ]  unit-test
100 121 [a..b] [
    [ test-tree2-floor-key 1array ] keep [ test-tree2 floor-node key>> ] curry unit-test
] each

99 120 [a..b] [
    [ test-tree2-ceiling-key 1array ] keep [ test-tree2 ceiling-node key>> ] curry unit-test
] each
{ f } [ 121 test-tree2 ceiling-node ]  unit-test

{ 100 } [ test-tree2 first-node key>> ] unit-test
{ 120 } [ test-tree2 last-node key>> ] unit-test

{ f } [ 99 test-tree2 lower-entry ] unit-test
{ f } [ 99 test-tree2 lower-key ] unit-test
{ f } [ 121 test-tree2 higher-entry ] unit-test
{ f } [ 121 test-tree2 higher-key ] unit-test
{ f } [ 99 test-tree2 floor-entry ] unit-test
{ f } [ 99 test-tree2 floor-key ] unit-test
{ f } [ 121 test-tree2 ceiling-entry ] unit-test
{ f } [ 121 test-tree2 ceiling-key ] unit-test
{ { 108 108 } } [ 110 test-tree2 lower-entry ] unit-test
{ 108  } [ 110 test-tree2 lower-key ] unit-test
{ { 112 112 } } [ 110 test-tree2 higher-entry ] unit-test
{ 112 } [ 110 test-tree2 higher-key ] unit-test
{ { 110 110 } } [ 110 test-tree2 floor-entry ] unit-test
{ 110 } [ 110 test-tree2 floor-key ] unit-test
{ { 110 110 } } [ 110 test-tree2 ceiling-entry ] unit-test
{ 110 } [ 110 test-tree2 ceiling-key ] unit-test

{ f } [ TREE{ } clone first-key ] unit-test
{ f } [ TREE{ } clone first-entry ] unit-test
{ f } [ TREE{ } clone last-key ] unit-test
{ f } [ TREE{ } clone last-entry ] unit-test
{ { 100 100 } } [ test-tree2 first-entry ] unit-test
{ 100 } [ test-tree2 first-key ] unit-test
{ { 120 120 } } [ test-tree2 last-entry ] unit-test
{ 120 } [ test-tree2 last-key ] unit-test

: ?a..b? ( a b ? ? -- range )
    2array {
        { { t t } [ [a..b] ] }
        { { t f } [ [a..b) ] }
        { { f t } [ (a..b] ] }
        { { f f } [ (a..b) ] }
    } case ;

! subtree>alist
: test-tree2-subtree>alist ( a b ? ? -- subalist )
    ?a..b? >array [ even? ] filter [ dup 2array ] map ;

: subtree>alist ( from-key to-key tree start-inclusive? end-inclusive? -- alist )
    2array {
        { { t f } [ subtree>alist[) ] }
        { { f t } [ subtree>alist(] ] }
        { { t t } [ subtree>alist[] ] }
        { { f f } [ subtree>alist() ] }
    } case ;

99 121 [a..b] 2 all-combinations
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


{ { { 10 10 } TREE{ { 20 20 } { 30 30 } } } } [
    TREE{ { 20 20 } { 10 10 } { 30 30 } } clone [
        pop-tree-left
    ] keep 2array
] unit-test

{ { { 30 30 } TREE{ { 20 20 } { 10 10 } } } } [
    TREE{ { 20 20 } { 10 10 } { 30 30 } } clone [
        pop-tree-right
    ] keep 2array
] unit-test

{ { { 20 20 } TREE{ } } } [
    TREE{ { 20 20 } } clone [
        pop-tree-right
    ] keep 2array
] unit-test

{ { { 20 20 } TREE{ } } } [
    TREE{ { 20 20 } } clone [
        pop-tree-left
    ] keep 2array
] unit-test

{ f } [ TREE{ } pop-tree-left ] unit-test
{ f } [ TREE{ } pop-tree-right ] unit-test

: with-limited-calls ( n quot -- quot' )
    [let
        0 :> count!
        '[ count _ >=
            [ "too many calls" throw ]
            [ count 1 + count! @ ] if
         ]
    ] ; inline


{ V{ { 10 10 } { 15 10 } { 20 20 }
    { 15 20 } { 30 30 } { 35 30 }
} } [
    TREE{ { 20 20 } { 10 10 } { 30 30 } } clone V{ } clone [
        dupd 6 [ [
                over first {
                    { [ dup 20 mod zero? ] [ drop [ first2 swap 5 - ] dip set-at ] }
                    { [ dup 10 mod zero? ] [ drop [ first2 swap 5 + ] dip set-at ] }
                    [ 3drop ]
                } cond
            ] [ push ] bi-curry* bi
        ] with-limited-calls 2curry slurp-tree-left
    ] keep
] unit-test

{ V{
    { 30 30 } { 25 30 } { 20 20 }
    { 25 20 } { 10 10 } {  5 10 } }
} [
    TREE{ { 20 20 } { 10 10 } { 30 30 } } clone V{ } clone [
        dupd 6 [ [
                over first {
                    { [ dup 20 mod zero? ] [ drop [ first2 swap 5 + ] dip set-at ] }
                    { [ dup 10 mod zero? ] [ drop [ first2 swap 5 - ] dip set-at ] }
                    [ 3drop ]
                } cond
            ] [ push ] bi-curry* bi
        ] with-limited-calls 2curry slurp-tree-right
    ] keep
] unit-test
