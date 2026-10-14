! Mesh collision needs neither a window nor GPU uploads.
USING: accessors alien alien.data alien.destructors arrays classes.struct
destructors kernel libc locals raylib sequences tools.test ;
IN: raylib.tests

: collision-test-mesh ( z -- mesh )
    [ -1 -1 ] dip <Vector3>
    -1 1 pick z>> <Vector3>
    1 -1 pick z>> <Vector3> 3array Vector3 >c-array >c-ptr malloc-byte-array &free
    Mesh new swap >>_vertices 3 >>vertexCount 1 >>triangleCount ;

: collision-test-model ( depths -- model )
    [ collision-test-mesh ] map Mesh >c-array
    Model new swap [ length >>meshCount ] [ >c-ptr malloc-byte-array &free >>_meshes ] bi
    dup transform>>
    1 >>m0 1 >>m5 1 >>m10 1 >>m15 drop ;

: collision-test-ray ( -- ray )
    Ray new 0 0 0 <Vector3> >>position
    0 0 1 <Vector3> >>direction ;

{ f } [ collision-test-ray Model new get-ray-collision-model hit>> ] unit-test
{ f } [ [ collision-test-ray { -2 -5 } collision-test-model get-ray-collision-model hit>> ] with-destructors ] unit-test
{ t 2.0 } [
    [ collision-test-ray { 5 2 } collision-test-model get-ray-collision-model
    [ hit>> ] [ distance>> ] bi ] with-destructors
] unit-test
{ t 2.0 } [
    [ collision-test-ray { 2 5 } collision-test-model get-ray-collision-model
    [ hit>> ] [ distance>> ] bi ] with-destructors
] unit-test
