IN: compiler.tree.recursive.tests
USING: compiler.tree.recursive tools.test
kernel combinators.short-circuit math sequences accessors
compiler.tree
compiler.tree.builder
compiler.tree.combinators ;

[ { f f f f } ] [ f { f t f f } (tail-calls) ] unit-test
[ { f f f t } ] [ t { f t f f } (tail-calls) ] unit-test
[ { f t t t } ] [ t { f f t t } (tail-calls) ] unit-test
[ { f f f t } ] [ t { f f t f } (tail-calls) ] unit-test

: label-is-loop? ( nodes word -- ? )
    [
        {
            [ drop #recursive? ]
            [ drop label>> loop?>> ]
            [ swap label>> word>> eq? ]
        } 2&&
    ] curry contains-node? ;

: label-is-not-loop? ( nodes word -- ? )
    [
        {
            [ drop #recursive? ]
            [ drop label>> loop?>> not ]
            [ swap label>> word>> eq? ]
        } 2&&
    ] curry contains-node? ;

: loop-test-1 ( a -- )
    dup [ 1+ loop-test-1 ] [ drop ] if ; inline recursive
                          
[ t ] [
    [ loop-test-1 ] build-tree analyze-recursive
    \ loop-test-1 label-is-loop?
] unit-test

[ t ] [
    [ loop-test-1 1 2 3 ] build-tree analyze-recursive
    \ loop-test-1 label-is-loop?
] unit-test

[ t ] [
    [ [ loop-test-1 ] each ] build-tree analyze-recursive
    \ loop-test-1 label-is-loop?
] unit-test

[ t ] [
    [ [ loop-test-1 ] each ] build-tree analyze-recursive
    \ (each-integer) label-is-loop?
] unit-test

: loop-test-2 ( a b -- a' )
    dup [ 1+ loop-test-2 1- ] [ drop ] if ; inline recursive

[ t ] [
    [ loop-test-2 ] build-tree analyze-recursive
    \ loop-test-2 label-is-not-loop?
] unit-test

: loop-test-3 ( a -- )
    dup [ [ loop-test-3 ] each ] [ drop ] if ; inline recursive

[ t ] [
    [ loop-test-3 ] build-tree analyze-recursive
    \ loop-test-3 label-is-not-loop?
] unit-test

: loop-test-4 ( a -- )
    dup [
        loop-test-4
    ] [
        drop
    ] if ; inline recursive

[ f ] [
    [ [ [ ] map ] map ] build-tree analyze-recursive
    [
        dup #recursive? [ label>> loop?>> not ] [ drop f ] if
    ] contains-node?
] unit-test

: blah ( -- value ) f ;

DEFER: a

: b ( -- )
    blah [ b ] [ a ] if ; inline recursive

: a ( -- )
    blah [ b ] [ a ] if ; inline recursive

[ t ] [
    [ a ] build-tree analyze-recursive
    \ a label-is-loop?
] unit-test

[ t ] [
    [ a ] build-tree analyze-recursive
    \ b label-is-loop?
] unit-test

[ t ] [
    [ b ] build-tree analyze-recursive
    \ a label-is-loop?
] unit-test

[ t ] [
    [ a ] build-tree analyze-recursive
    \ b label-is-loop?
] unit-test

DEFER: a'

: b' ( -- )
    blah [ b' b' ] [ a' ] if ; inline recursive

: a' ( -- )
    blah [ b' ] [ a' ] if ; inline recursive

[ f ] [
    [ a' ] build-tree analyze-recursive
    \ a' label-is-loop?
] unit-test

[ f ] [
    [ b' ] build-tree analyze-recursive
    \ b' label-is-loop?
] unit-test

! I used to think this should be f, but doing this on pen and
! paper almost convinced me that a loop conversion here is
! sound.

[ t ] [
    [ b' ] build-tree analyze-recursive
    \ a' label-is-loop?
] unit-test

[ f ] [
    [ a' ] build-tree analyze-recursive
    \ b' label-is-loop?
] unit-test

DEFER: a''

: b'' ( -- )
    a'' ; inline recursive

: a'' ( -- )
    b'' a'' ; inline recursive

[ t ] [
    [ a'' ] build-tree analyze-recursive
    \ a'' label-is-not-loop?
] unit-test

: loop-in-non-loop ( x quot: ( i -- ) -- )
    over 0 > [
        [ [ 1 - ] dip loop-in-non-loop ] [ call ] 2bi
    ] [ 2drop ] if ; inline recursive

[ t ] [
    [ 10 [ [ drop ] each-integer ] loop-in-non-loop ]
    build-tree analyze-recursive
    \ (each-integer) label-is-loop?
] unit-test
