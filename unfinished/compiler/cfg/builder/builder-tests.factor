IN: compiler.cfg.builder.tests
USING: compiler.cfg.builder tools.test kernel sequences
math.private compiler.tree.builder compiler.tree.optimizer
words sequences.private fry prettyprint alien ;

! Just ensure that various CFGs build correctly.
: test-cfg ( quot -- result )
    build-tree optimize-tree gensym gensym build-cfg ;

{
    [ ]
    [ dup ]
    [ swap ]
    [ >r r> ]
    [ fixnum+ ]
    [ fixnum< ]
    [ [ 1 ] [ 2 ] if ]
    [ fixnum< [ 1 ] [ 2 ] if ]
    [ float+ [ 2.0 float* ] [ 3.0 float* ] bi float/f ]
    [ { [ 1 ] [ 2 ] [ 3 ] } dispatch ]
    [ [ t ] loop ]
    [ [ dup ] loop ]
    [ [ 2 ] [ 3 throw ] if 4 ]
    [ "int" f "malloc" { "int" } alien-invoke ]
    [ "int" { "int" } "cdecl" alien-indirect ]
    [ "int" { "int" } "cdecl" [ ] alien-callback ]
} [
    '[ _ test-cfg drop ] [ ] swap unit-test
] each

: test-word-cfg ( word -- result )
    [ build-tree-from-word nip optimize-tree ] keep dup
    build-cfg ;

: test-1 ( -- ) test-1 ;
: test-2 ( -- ) 3 . test-2 ;
: test-3 ( a -- b ) dup [ test-3 ] when ;

{
    test-1
    test-2
    test-3
} [
    '[ _ test-word-cfg drop ] [ ] swap unit-test
] each
