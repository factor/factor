USING: kernel math math.matrices math.matrices.extras
math.order math.vectors prettyprint sequences ;
IN: benchmark.3d-matrix-scalar

:: p-matrix ( dim fov near far -- matrix )
    dim dup first2 min v/n fov v*n near v*n
    near far <frustum-matrix4> ;

:: mv-matrix ( pitch yaw location -- matrix )
    { 1.0 0.0 0.0 } pitch <rotation-matrix4>
    { 0.0 1.0 0.0 } yaw   <rotation-matrix4>
    location vneg <translation-matrix4> mdot mdot ;

:: 3d-matrix-scalar-benchmark ( -- )
    f :> result!
    100000 [
        { 1024.0 768.0 } 0.7 0.25 1024.0 p-matrix :> p
        3.0 1.0 { 10.0 -0.0 2.0 } mv-matrix :> mv
        mv p mdot result!
    ] times
    result . ;

MAIN: 3d-matrix-scalar-benchmark
