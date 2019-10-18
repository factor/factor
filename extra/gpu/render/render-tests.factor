USING: accessors combinators gpu.render gpu.render.private kernel sequences tools.test ;
IN: gpu.render.tests

UNIFORM-TUPLE: two-textures
    { "argyle"       texture-uniform f }
    { "thread-count" float-uniform   f }
    { "tweed"        texture-uniform f } ;

UNIFORM-TUPLE: inherited-textures < two-textures
    { "paisley" texture-uniform f } ;

UNIFORM-TUPLE: array-of-textures < two-textures
    { "plaids" texture-uniform 4 } ;

UNIFORM-TUPLE: struct-containing-texture
    { "threads" two-textures f } ;

UNIFORM-TUPLE: array-of-struct-containing-texture
    { "threads" inherited-textures 3 } ;

UNIFORM-TUPLE: array-of-struct-containing-array-of-texture
    { "threads" array-of-textures 2 } ;

{  1 } [ texture-uniform uniform-type-texture-units ] unit-test
{  0 } [ float-uniform uniform-type-texture-units ] unit-test
{  2 } [ two-textures uniform-type-texture-units ] unit-test
{  3 } [ inherited-textures uniform-type-texture-units ] unit-test
{  6 } [ array-of-textures uniform-type-texture-units ] unit-test
{  2 } [ struct-containing-texture uniform-type-texture-units ] unit-test
{  9 } [ array-of-struct-containing-texture uniform-type-texture-units ] unit-test
{ 12 } [ array-of-struct-containing-array-of-texture uniform-type-texture-units ] unit-test

{ { [ ] } } [ texture-uniform f uniform-texture-accessors ] unit-test

{ { } } [ float-uniform f uniform-texture-accessors ] unit-test

{ { [ argyle>> ] [ tweed>> ] } } [ two-textures f uniform-texture-accessors ] unit-test

{ { [ argyle>> ] [ tweed>> ] [ paisley>> ] } }
[ inherited-textures f uniform-texture-accessors ] unit-test

{ {
    [ argyle>> ]
    [ tweed>> ]
    [ plaids>> {
        [ 0 swap nth ]
        [ 1 swap nth ]
        [ 2 swap nth ]
        [ 3 swap nth ]
    } ]
} } [ array-of-textures f uniform-texture-accessors ] unit-test

{ {
    [ threads>> {
        [ argyle>> ]
        [ tweed>> ]
    } ]
} } [ struct-containing-texture f uniform-texture-accessors ] unit-test

{ {
    [ threads>> {
        [ 0 swap nth {
            [ argyle>> ]
            [ tweed>> ]
            [ paisley>> ]
        } ]
        [ 1 swap nth {
            [ argyle>> ]
            [ tweed>> ]
            [ paisley>> ]
        } ]
        [ 2 swap nth {
            [ argyle>> ]
            [ tweed>> ]
            [ paisley>> ]
        } ]
    } ]
} } [ array-of-struct-containing-texture f uniform-texture-accessors ] unit-test

{ {
    [ threads>> {
        [ 0 swap nth {
            [ argyle>> ]
            [ tweed>> ]
            [ plaids>> {
                [ 0 swap nth ]
                [ 1 swap nth ]
                [ 2 swap nth ]
                [ 3 swap nth ]
            } ]
        } ]
        [ 1 swap nth {
            [ argyle>> ]
            [ tweed>> ]
            [ plaids>> {
                [ 0 swap nth ]
                [ 1 swap nth ]
                [ 2 swap nth ]
                [ 3 swap nth ]
            } ]
        } ]
    } ]
} } [ array-of-struct-containing-array-of-texture f uniform-texture-accessors ] unit-test

{ [
    nip {
        [ argyle>> 0 (bind-texture-unit) ]
        [ tweed>> 1 (bind-texture-unit) ]
        [ plaids>> {
            [ 0 swap nth 2 (bind-texture-unit) ]
            [ 1 swap nth 3 (bind-texture-unit) ]
            [ 2 swap nth 4 (bind-texture-unit) ]
            [ 3 swap nth 5 (bind-texture-unit) ]
        } cleave ]
    } cleave
] } [ array-of-textures [bind-uniform-textures] ] unit-test
