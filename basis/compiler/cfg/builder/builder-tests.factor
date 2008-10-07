IN: compiler.cfg.builder.tests
USING: tools.test kernel sequences
words sequences.private fry prettyprint alien
math.private compiler.tree.builder compiler.tree.optimizer
compiler.cfg.builder compiler.cfg.debugger  ;

! Just ensure that various CFGs build correctly.
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

: test-1 ( -- ) test-1 ;
: test-2 ( -- ) 3 . test-2 ;
: test-3 ( a -- b ) dup [ test-3 ] when ;

{
    test-1
    test-2
    test-3
} [
    '[ _ test-cfg drop ] [ ] swap unit-test
] each
