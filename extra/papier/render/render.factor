! (c)2010 Joe Groff bsd license
USING: accessors alien.c-types alien.data.map combinators fry
gpu.buffers gpu.framebuffers gpu.render gpu.shaders gpu.state
images images.atlas kernel locals math math.matrices.simd
math.order math.vectors math.vectors.simd papier.map sequences
sorting typed ;
IN: papier.render

CONSTANT: slab-buffer-chunk-size 1024

GLSL-SHADER-FILE: papier-vertex-shader vertex-shader "papier.v.glsl"
GLSL-SHADER-FILE: papier-fragment-shader fragment-shader "papier.f.glsl"
GLSL-PROGRAM: papier-program
    papier-vertex-shader papier-fragment-shader
    papier-vertex ;

UNIFORM-TUPLE: papier-uniforms
    { "p_matrix" mat4-uniform    f }
    { "eye"      vec3-uniform    f }
    { "atlas"    texture-uniform f } ;

TUPLE: papier-renderer
    { vertex-buffer buffer }
    { index-buffer buffer }
    { vertex-array vertex-array initial: T{ vertex-array-object } } ;

: set-papier-state ( -- )
    {
        T{ blend-state { rgb-mode T{ blend-mode } } { alpha-mode T{ blend-mode } } }
    } set-gpu-state ;

TYPED:: <papier-renderer> ( -- renderer: papier-renderer )
    papier-renderer new
        stream-upload draw-usage index-buffer  slab-buffer-chunk-size f <buffer> >>index-buffer
        stream-upload draw-usage vertex-buffer slab-buffer-chunk-size f <buffer>
        [ >>vertex-buffer ]
        [ papier-program <program-instance> <vertex-array> >>vertex-array ] bi ;

:: <p-matrix> ( dim fov near-plane far-plane -- matrix )
    dim dup first2 min >float v/n fov v*n near-plane v*n
    near-plane far-plane frustum-matrix4 ; inline

: slab-vertices ( slab -- av at ac bv bt bc cv ct cc dv dt dc )
    [ matrix>> ] [ [ frame>> ] [ texcoords>> ] bi nth ] [ color>> ] tri {
        [ [ float-4{ -1 -1 0 1 } m4.v ] [                      ] [ ] tri* ]
        [ [ float-4{  1 -1 0 1 } m4.v ] [ { 2 1 0 3 } vshuffle ] [ ] tri* ]
        [ [ float-4{ -1  1 0 1 } m4.v ] [ { 0 3 2 1 } vshuffle ] [ ] tri* ]
        [ [ float-4{  1  1 0 1 } m4.v ] [ { 2 3 0 1 } vshuffle ] [ ] tri* ]
    } 3cleave ; inline

: slab-indexes ( i -- a b c d e f )
    4 * { [ ] [ 1 + ] [ 2 + ] [ 2 + ] [ 1 + ] [ 3 + ] } cleave ; inline

: order-slabs ( slabs eye -- slabs' )
    ! NO
    ! '[ center>> _ v- norm-sq ] inv-sort-by ; inline
    drop ;

: render-slabs ( slabs -- vertices indexes )
    dup length <iota> [
        [ slab-vertices ]
        [ slab-indexes ] bi* 
    ] data-map( object object -- float-4[12] uint[6] ) ; inline

TYPED:: render-slabs-to-buffers ( renderer: papier-renderer uniforms: papier-uniforms slabs -- )
    slabs uniforms eye>> order-slabs render-slabs :> ( vertices indexes )
    renderer vertex-buffer>> vertices allocate-byte-array
    renderer index-buffer>> indexes allocate-byte-array ; inline

: slab-index-count ( slabs -- count )
    length 6 * ; inline

TYPED: prep-slab-atlas ( slabs images -- atlas-image: image )
    make-atlas-assoc [ update-slabs-for-atlas ] dip ;

TYPED:: draw-slabs ( renderer: papier-renderer uniforms: papier-uniforms slabs -- )
    system-framebuffer { { default-attachment { 0.0 0.0 0.0 0.0 } } } clear-framebuffer

    renderer uniforms slabs render-slabs-to-buffers

    renderer index-buffer>> 0 <buffer-ptr> slabs slab-index-count
    uint-indexes <index-elements> :> indexes

    renderer vertex-array>> :> vertex-array
    
    triangles-mode
    vertex-array
    uniforms
    indexes
    f
    system-framebuffer
    { default-attachment }
    f render-set boa render ;

