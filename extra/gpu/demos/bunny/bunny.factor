! (c)2009 Joe Groff bsd license
USING: accessors alien.c-types arrays classes.struct combinators
combinators.short-circuit game-worlds gpu gpu.buffers
gpu.util.wasd gpu.framebuffers gpu.render gpu.shaders gpu.state
gpu.textures gpu.util grouping http.client images images.loader
io io.encodings.ascii io.files io.files.temp kernel math
math.matrices math.parser math.vectors method-chains sequences
splitting threads ui ui.gadgets ui.gadgets.worlds
ui.pixel-formats specialized-arrays specialized-vectors ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
SPECIALIZED-VECTOR: uint
IN: gpu.demos.bunny

GLSL-SHADER-FILE: bunny-vertex-shader vertex-shader "bunny.v.glsl"
GLSL-SHADER-FILE: bunny-fragment-shader fragment-shader "bunny.f.glsl"
GLSL-PROGRAM: bunny-program
    bunny-vertex-shader bunny-fragment-shader ;

GLSL-SHADER-FILE: window-vertex-shader vertex-shader "window.v.glsl"

GLSL-SHADER-FILE: sobel-fragment-shader fragment-shader "sobel.f.glsl"
GLSL-PROGRAM: sobel-program
    window-vertex-shader sobel-fragment-shader ;

GLSL-SHADER-FILE: loading-fragment-shader fragment-shader "loading.f.glsl"
GLSL-PROGRAM: loading-program
    window-vertex-shader loading-fragment-shader ;

TUPLE: bunny-state
    vertexes
    indexes
    vertex-array
    index-elements ;

TUPLE: sobel-state
    vertex-array
    color-texture
    normal-texture
    depth-texture
    framebuffer ;

TUPLE: loading-state
    vertex-array
    texture ;

TUPLE: bunny-world < wasd-world
    bunny sobel loading ;

VERTEX-FORMAT: bunny-vertex
    { "vertex" float-components 3 f }
    { f        float-components 1 f }
    { "normal" float-components 3 f }
    { f        float-components 1 f } ;
VERTEX-STRUCT: bunny-vertex-struct bunny-vertex

SPECIALIZED-VECTOR: bunny-vertex-struct

UNIFORM-TUPLE: bunny-uniforms < mvp-uniforms
    { "light-position" vec3-uniform  f }
    { "color"          vec4-uniform  f }
    { "ambient"        vec4-uniform  f }
    { "diffuse"        vec4-uniform  f }
    { "shininess"      float-uniform f } ;

UNIFORM-TUPLE: sobel-uniforms
    { "texcoord-scale" vec2-uniform    f }
    { "color-texture"  texture-uniform f }
    { "normal-texture" texture-uniform f }
    { "depth-texture"  texture-uniform f }
    { "line-color"     vec4-uniform    f } ; 

UNIFORM-TUPLE: loading-uniforms
    { "texcoord-scale"  vec2-uniform    f }
    { "loading-texture" texture-uniform f } ;

: numbers ( str -- seq )
    " " split [ string>number ] map sift ;

: <bunny-vertex> ( vertex -- struct )
    bunny-vertex-struct <struct>
        swap >float-array >>vertex ; inline

: (parse-bunny-model) ( vs is -- vs is )
    readln [
        numbers {
            { [ dup length 5 = ] [ 3 head <bunny-vertex> pick push ] }
            { [ dup first 3 = ] [ rest over push-all ] }
            [ drop ]
        } cond (parse-bunny-model)
    ] when* ;

: parse-bunny-model ( -- vertexes indexes )
    100000 <bunny-vertex-struct-vector>
    100000 <uint-vector>
    (parse-bunny-model) ;

: normal ( vertexes -- normal )
    [ [ second ] [ first ] bi v- ]
    [ [ third  ] [ first ] bi v- ] bi cross
    vneg normalize ; inline

: calc-bunny-normal ( vertexes indexes -- )
    swap
    [ [ nth vertex>> ] curry { } map-as normal ]
    [ [ nth [ v+ ] change-normal drop ] curry with each ] 2bi ;

: calc-bunny-normals ( vertexes indexes -- )
    3 <groups>
    [ calc-bunny-normal ] with each ;

: normalize-bunny-normals ( vertexes -- )
    [ [ normalize ] change-normal drop ] each ;

: bunny-data ( filename -- vertexes indexes )
    ascii [ parse-bunny-model ] with-file-reader
    [ calc-bunny-normals ]
    [ drop normalize-bunny-normals ]
    [ ] 2tri ;

: <bunny-buffers> ( vertexes indexes -- vertex-buffer index-buffer index-count )
    [ underlying>> static-upload draw-usage vertex-buffer byte-array>buffer ]
    [
        [ underlying>> static-upload draw-usage index-buffer  byte-array>buffer ]
        [ length ] bi
    ] bi* ;

: bunny-model-path ( -- path ) "bun_zipper.ply" temp-file ;

CONSTANT: bunny-model-url "http://factorcode.org/bun_zipper.ply"

: download-bunny ( -- path )
    bunny-model-path dup exists? [
        bunny-model-url dup print flush
        over download-to
    ] unless ;

: get-bunny-data ( bunny-state -- )
    download-bunny bunny-data
    [ >>vertexes ] [ >>indexes ] bi* drop ;

: fill-bunny-state ( bunny-state -- )
    dup [ vertexes>> ] [ indexes>> ] bi <bunny-buffers>
    [ bunny-program <program-instance> bunny-vertex buffer>vertex-array >>vertex-array ]
    [ 0 <buffer-ptr> ]
    [ uint-indexes <index-elements> >>index-elements ] tri*
    drop ;

: <bunny-state> ( -- bunny-state )
    bunny-state new
    dup [ get-bunny-data ] curry "Downloading bunny model" spawn drop ;

: bunny-loaded? ( bunny-state -- ? )
    { [ vertexes>> ] [ indexes>> ] } 1&& ;

: bunny-state-filled? ( bunny-state -- ? )
    { [ vertex-array>> ] [ index-elements>> ] } 1&& ;

: <sobel-state> ( window-vertex-buffer -- sobel-state )
    sobel-state new
        swap sobel-program <program-instance> window-vertex buffer>vertex-array >>vertex-array

        RGBA half-components T{ texture-parameters
            { wrap clamp-texcoord-to-edge }
            { min-filter filter-linear }
            { min-mipmap-filter f }
        } <texture-2d> >>color-texture
        RGBA half-components T{ texture-parameters
            { wrap clamp-texcoord-to-edge }
            { min-filter filter-linear }
            { min-mipmap-filter f }
        } <texture-2d> >>normal-texture
        DEPTH u-24-components T{ texture-parameters
            { wrap clamp-texcoord-to-edge }
            { min-filter filter-linear }
            { min-mipmap-filter f }
        } <texture-2d> >>depth-texture

        dup
        [
            [ color-texture>>  0 <texture-2d-attachment> ]
            [ normal-texture>> 0 <texture-2d-attachment> ] bi 2array
        ] [ depth-texture>> 0 <texture-2d-attachment> ] bi f { 1024 768 } <framebuffer> >>framebuffer ;

: <loading-state> ( window-vertex-buffer -- loading-state )
    loading-state new
        swap
        loading-program <program-instance> window-vertex buffer>vertex-array >>vertex-array

        RGBA ubyte-components T{ texture-parameters
            { wrap clamp-texcoord-to-edge }
            { min-filter filter-linear }
            { min-mipmap-filter f }
        } <texture-2d>
        dup 0 "vocab:gpu/demos/bunny/loading.tiff" load-image allocate-texture-image
        >>texture ;

BEFORE: bunny-world begin-world
    init-gpu
    
    { -0.2 0.13 0.1 } 1.1 0.2 set-wasd-view

    <bunny-state> >>bunny
    <window-vertex-buffer>
    [ <sobel-state> >>sobel ]
    [ <loading-state> >>loading ] bi
    drop ;

: <bunny-uniforms> ( world -- uniforms )
    [ wasd-mv-matrix ] [ wasd-p-matrix ] bi
    { -10000.0 10000.0 10000.0 } ! light position
    { 0.6 0.5 0.5 1.0 } ! color
    { 0.2 0.2 0.2 0.2 } ! ambient
    { 0.8 0.8 0.8 0.8 } ! diffuse
    100.0 ! shininess
    bunny-uniforms boa ;

: draw-bunny ( world -- )
    T{ depth-state { comparison cmp-less } } set-gpu-state
    
    [
        sobel>> framebuffer>> {
            { T{ color-attachment f 0 } { 0.15 0.15 0.15 1.0 } }
            { T{ color-attachment f 1 } { 0.0 0.0 0.0 0.0 } }
            { depth-attachment 1.0 }
        } clear-framebuffer
    ] [
        {
            { "primitive-mode"     [ drop triangles-mode ] }
            { "output-attachments" [ drop { T{ color-attachment f 0 } T{ color-attachment f 1 } } ] }
            { "uniforms"           [ <bunny-uniforms> ] }
            { "vertex-array"       [ bunny>> vertex-array>> ] }
            { "indexes"            [ bunny>> index-elements>> ] }
            { "framebuffer"        [ sobel>> framebuffer>> ] }
        } <render-set> render
    ] bi ;

: <sobel-uniforms> ( sobel -- uniforms )
    { 1.0 1.0 } swap
    [ color-texture>> ] [ normal-texture>> ] [ depth-texture>> ] tri
    { 0.1 0.0 0.1 1.0 } ! line_color
    sobel-uniforms boa ;

: draw-sobel ( world -- )
    T{ depth-state { comparison f } } set-gpu-state

    sobel>> {
        { "primitive-mode" [ drop triangle-strip-mode ] }
        { "indexes"        [ drop T{ index-range f 0 4 } ] }
        { "uniforms"       [ <sobel-uniforms> ] }
        { "vertex-array"   [ vertex-array>> ] }
    } <render-set> render ;

: draw-sobeled-bunny ( world -- )
    [ draw-bunny ] [ draw-sobel ] bi ;

: draw-loading ( world -- )
    T{ depth-state { comparison f } } set-gpu-state

    loading>> {
        { "primitive-mode" [ drop triangle-strip-mode ] }
        { "indexes"        [ drop T{ index-range f 0 4 } ] }
        { "uniforms"       [ { 1.0 -1.0 } swap texture>> loading-uniforms boa ] }
        { "vertex-array"   [ vertex-array>> ] }
    } <render-set> render ;

M: bunny-world draw-world*
    dup bunny>>
    dup bunny-loaded? [
        dup bunny-state-filled? [ drop ] [ fill-bunny-state ] if
        draw-sobeled-bunny
    ] [ drop draw-loading ] if ;

AFTER: bunny-world resize-world
    [ sobel>> framebuffer>> ] [ dim>> ] bi resize-framebuffer ;

M: bunny-world pref-dim* drop { 1024 768 } ;
M: bunny-world tick-length drop 1000 30 /i ;
M: bunny-world wasd-movement-speed drop 1/160. ;
M: bunny-world wasd-near-plane drop 1/32. ;
M: bunny-world wasd-far-plane drop 256.0 ;

: bunny-window ( -- )
    [
        f T{ world-attributes
            { world-class bunny-world }
            { title "Bunny" }
            { pixel-format-attributes {
                windowed
                double-buffered
                T{ depth-bits { value 24 } }
            } }
            { grab-input? t }
        } open-window
    ] with-ui ;

MAIN: bunny-window
