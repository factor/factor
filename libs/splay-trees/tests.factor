USING: kernel math namespaces sequences words splay-trees-internals
splay-trees test ;

<splay-tree> "foo" set
all-words [ dup word-name "foo" get set-splay ] each
all-words [ word-name "foo" get get-splay drop ] each

: randomize-numeric-splay-tree ( splay-tree -- )
    100 [ drop 100 random swap get-splay drop ] each-with ;

: make-numeric-splay-tree ( n -- splay-tree )
    dup <splay-tree> -rot [ pick set-splay ] 2each ;

[ t ] [
    100 make-numeric-splay-tree dup randomize-numeric-splay-tree [
        drop ,
    ] [
        splay-tree-traverse
    ] { } make [ < ] monotonic?
] unit-test

[ 10 ] [ 10 make-numeric-splay-tree splay-keys length ] unit-test
[ 10 ] [ 10 make-numeric-splay-tree splay-values length ] unit-test

[ f ] [ <splay-tree> f 4 pick set-splay 4 swap get-splay ] unit-test

! Ensure that f can be a value
[ t ] [ <splay-tree> f 4 pick set-splay 4 swap get-splay* nip ] unit-test

[
{ { 1 "a" } { 2 "b" } { 3 "c" } { 4 "d" } { 5 "e" } { 6 "f" } }
] [
{
    { 4 "d" } { 5 "e" } { 6 "f" }
    { 1 "a" } { 2 "b" } { 3 "c" }
} assoc>splay splay>assoc
] unit-test
