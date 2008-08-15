IN: compiler.tree.normalization.tests
USING: compiler.tree.builder compiler.tree.normalization
compiler.tree sequences accessors tools.test kernel math ;

\ count-introductions must-infer
\ normalize must-infer

[ 3 ] [ [ 3drop 1 2 3 ] build-tree count-introductions ] unit-test

[ 4 ] [ [ 3drop 1 2 3 3drop drop ] build-tree count-introductions ] unit-test

[ 3 ] [ [ [ drop ] [ 2drop 3 ] if ] build-tree count-introductions ] unit-test

[ 2 ] [ [ 3 [ drop ] [ 2drop 3 ] if ] build-tree count-introductions ] unit-test

: foo ( -- ) swap ; inline recursive

: recursive-inputs ( nodes -- n )
    [ #recursive? ] find nip child>> first in-d>> length ;

[ 0 2 ] [
    [ foo ] build-tree
    [ recursive-inputs ]
    [ normalize recursive-inputs ] bi
] unit-test

[ ] [ [ [ 1 ] [ 2 ] if + * ] build-tree normalize drop ] unit-test

DEFER: bbb
: aaa ( x -- ) dup [ dup >r bbb r> aaa ] [ drop ] if ; inline recursive
: bbb ( x -- ) >r drop 0 r> aaa ; inline recursive

[ ] [ [ bbb ] build-tree normalize drop ] unit-test

: ccc ( -- ) ccc drop 1 ; inline recursive

[ ] [ [ ccc ] build-tree normalize drop ] unit-test

DEFER: eee
: ddd ( -- ) eee ; inline recursive
: eee ( -- ) swap ddd ; inline recursive

[ ] [ [ eee ] build-tree normalize drop ] unit-test
