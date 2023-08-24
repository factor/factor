USING: tools.test compiler.tree
compiler.tree.builder compiler.tree.recursive
compiler.tree.normalization compiler.tree.propagation
compiler.tree.cleanup compiler.tree.escape-analysis
compiler.tree.tuple-unboxing compiler.tree.checker
compiler.tree.def-use kernel accessors sequences math
math.private sorting math.order binary-search sequences.private
slots.private alien alien.c-types ;
IN: compiler.tree.tuple-unboxing.tests

: test-unboxing ( quot -- )
    build-tree
    analyze-recursive
    normalize
    propagate
    cleanup-tree
    escape-analysis
    unbox-tuples
    check-nodes ;

TUPLE: cons { car read-only } { cdr read-only } ;

TUPLE: empty-tuple ;

{
    [ 1 2 cons boa [ car>> ] [ cdr>> ] bi ]
    [ empty-tuple boa drop ]
    [ cons boa [ car>> ] [ cdr>> ] bi ]
    [ [ 1 cons boa ] [ 2 cons boa ] if car>> ]
    [ dup cons boa 10 [ nip dup cons boa ] each-integer car>> ]
    [ 2 cons boa { [ ] [ ] } dispatch ]
    [ dup [ drop f ] [ "A" throw ] if ]
    [ [ ] [ ] curry curry dup 2 slot swap 3 slot dup 2 slot swap 3 slot drop ]
    [ [ ] [ ] curry curry call ]
    [ 1 cons boa over [ "A" throw ] when car>> ]
    [ [ <=> ] sort-with ]
    [ [ <=> ] with search ]
    [ cons boa car>> void { } cdecl [ ] alien-callback ]
} [ [ ] swap [ test-unboxing ] curry unit-test ] each

! A more complicated example
: impeach-node ( quot: ( ..a -- ..b ) -- )
    [ call ] keep impeach-node ; inline recursive

: bleach-node ( quot: ( ..a -- ..b ) -- )
    [ bleach-node ] curry [ ] compose impeach-node ; inline recursive

{ } [ [ [ ] bleach-node ] test-unboxing ] unit-test

TUPLE: box { i read-only } ;

: box-test ( m -- n )
    dup box-test i>> swap box-test drop box boa ; inline recursive

{ } [ [ T{ box f 34 } box-test i>> ] test-unboxing ] unit-test
