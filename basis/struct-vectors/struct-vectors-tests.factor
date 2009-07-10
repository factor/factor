IN: struct-vectors.tests
USING: struct-vectors tools.test alien.c-types alien.syntax
namespaces kernel sequences ;

C-STRUCT: point
    { "float" "x" }
    { "float" "y" } ;

: make-point ( x y -- point )
    "point" <c-object>
    [ set-point-y ] keep
    [ set-point-x ] keep ;

[ ] [ 1 "point" <struct-vector> "v" set ] unit-test

[ 1.5 6.0 ] [
    1.0 2.0 make-point "v" get push
    3.0 4.5 make-point "v" get push
    1.5 6.0 make-point "v" get push
    "v" get pop [ point-x ] [ point-y ] bi
] unit-test