USING: kernel math math.matrices.simd math.vectors
math.vectors.simd prettyprint typed ;
QUALIFIED-WITH: alien.c-types c
IN: benchmark.3d-matrix-vector

: v2min ( xy -- xx )
    dup { 1 0 2 3 } vshuffle vmin ; inline

TYPED:: p-matrix ( dim: float-4 fov: float near: float far: float -- matrix: matrix4 )
    dim dup v2min v/ fov v*n near v*n
    near far frustum-matrix4 ;

TYPED:: mv-matrix ( pitch: float yaw: float location: float-4 -- matrix: matrix4 )
    float-4{ 1.0 0.0 0.0 0.0 } pitch rotation-matrix4
    float-4{ 0.0 1.0 0.0 0.0 } yaw   rotation-matrix4
    location vneg translation-matrix4 m4. m4. ;

:: 3d-matrix-vector-benchmark ( -- )
    f :> result!
    100000 [
        float-4{ 1024.0 768.0 0.0 0.0 } 0.7 0.25 1024.0 p-matrix :> p
        3.0 1.0 float-4{ 10.0 -0.0 2.0 0.0 } mv-matrix :> mv
        mv p m4. result!
    ] times
    result . ;

MAIN: 3d-matrix-vector-benchmark
