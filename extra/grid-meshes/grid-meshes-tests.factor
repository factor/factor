USING: alien.c-types alien.data grid-meshes grid-meshes.private
specialized-arrays tools.test ;
SPECIALIZED-ARRAY: float

{
    float-array{
        0.0 0.0 0.0 1.0
        0.0 0.0 0.5 1.0
        0.5 0.0 0.0 1.0
        0.5 0.0 0.5 1.0
        1.0 0.0 0.0 1.0
        1.0 0.0 0.5 1.0
        0.0 0.0 0.5 1.0
        0.0 0.0 1.0 1.0
        0.5 0.0 0.5 1.0
        0.5 0.0 1.0 1.0
        1.0 0.0 0.5 1.0
        1.0 0.0 1.0 1.0
    }
} [ { 2 2 } vertex-array float cast-array ] unit-test
