IN: struct-vectors.tests
USING: struct-vectors tools.test alien.c-types classes.struct accessors
namespaces kernel sequences ;

STRUCT: point { x float } { y float } ;

: make-point ( x y -- point ) point <struct-boa> ;

[ ] [ 1 point <struct-vector> "v" set ] unit-test

[ 1.5 6.0 ] [
    1.0 2.0 make-point "v" get push
    3.0 4.5 make-point "v" get push
    1.5 6.0 make-point "v" get push
    "v" get pop [ x>> ] [ y>> ] bi
] unit-test