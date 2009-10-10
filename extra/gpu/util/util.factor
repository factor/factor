! (c)2009 Joe Groff bsd license
USING: gpu.buffers gpu.render gpu.shaders gpu.textures images kernel
specialized-arrays ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
IN: gpu.util

CONSTANT: environment-cube-map-mv-matrices
    H{
        { +X {
            {  0.0  0.0 -1.0  0.0 }
            {  0.0 -1.0  0.0  0.0 }
            { -1.0  0.0  0.0  0.0 }
            {  0.0  0.0  0.0  1.0 }
        } }
        { +Y {
            {  1.0  0.0  0.0  0.0 }
            {  0.0  0.0  1.0  0.0 }
            {  0.0 -1.0  0.0  0.0 }
            {  0.0  0.0  0.0  1.0 }
        } }
        { +Z {
            {  1.0  0.0  0.0  0.0 }
            {  0.0 -1.0  0.0  0.0 }
            {  0.0  0.0 -1.0  0.0 }
            {  0.0  0.0  0.0  1.0 }
        } }
        { -X {
            {  0.0  0.0  1.0  0.0 }
            {  0.0 -1.0  0.0  0.0 }
            {  1.0  0.0  0.0  0.0 }
            {  0.0  0.0  0.0  1.0 }
        } }
        { -Y {
            {  1.0  0.0  0.0  0.0 }
            {  0.0  0.0 -1.0  0.0 }
            {  0.0  1.0  0.0  0.0 }
            {  0.0  0.0  0.0  1.0 }
        } }
        { -Z {
            { -1.0  0.0  0.0  0.0 }
            {  0.0 -1.0  0.0  0.0 }
            {  0.0  0.0  1.0  0.0 }
            {  0.0  0.0  0.0  1.0 }
        } }
    }

VERTEX-FORMAT: window-vertex
    { "vertex" float-components 2 f } ;

CONSTANT: window-vertexes
    float-array{
        -1.0 -1.0
        -1.0  1.0
         1.0 -1.0
         1.0  1.0
    }

: <window-vertex-buffer> ( -- buffer )
    window-vertexes 
    static-upload draw-usage vertex-buffer
    byte-array>buffer ;

: <window-vertex-array> ( program-instance -- vertex-array )
    [ <window-vertex-buffer> ] dip window-vertex buffer>vertex-array ;
