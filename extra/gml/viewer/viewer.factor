USING: accessors alien.c-types alien.data alien.data.map arrays
assocs byte-arrays colors combinators combinators.short-circuit
destructors euler.b-rep euler.b-rep.triangulation game.input
game.loop game.models.half-edge game.worlds gml.printer gpu
gpu.buffers gpu.framebuffers gpu.render gpu.shaders gpu.state
gpu.util.wasd growable images kernel literals math math.order
math.vectors math.vectors.conversion math.vectors.simd
math.vectors.simd.cords method-chains models namespaces ranges
sequences sets specialized-vectors typed ui ui.gadgets
ui.gadgets.worlds ui.gestures ui.pixel-formats vectors ;
FROM: models => change-model ;
SPECIALIZED-VECTORS: ushort float-4 ;
IN: gml.viewer

CONSTANT: neutral-edge-color float-4{ 1 1 1 1 }
CONSTANT: neutral-face-color float-4{ 1 1 1 1 }
CONSTANT: selected-face-color float-4{ 1 0.9 0.8 1 }

: double-4>float-4 ( in: double-4 -- out: float-4 )
    [ head>> ] [ tail>> ] bi double-2 float-4 vconvert ; inline
: rgba>float-4 ( in: rgba -- out: float-4 )
    >rgba-components float-4-boa ; inline

: face-color ( edge -- color )
    face-normal float-4{ 0 1 0.1 0 } vdot 0.3 * 0.4 + dup dup 1.0 float-4-boa ; inline

TUPLE: b-rep-vertices
    { array byte-array read-only }
    { face-vertex-count integer read-only }
    { edge-vertex-count integer read-only }
    { point-vertex-count integer read-only } ;

:: <b-rep-vertices> ( face-array  face-count
                      edge-array  edge-count
                      point-array point-count -- vxs )
    face-array edge-array point-array 3append
    face-count edge-count point-count \ b-rep-vertices boa ; inline

: face-selected? ( face selected -- ? )
    [ f ] 2dip [ edge>> ] dip '[ _ in? or ] each-face-edge ;

:: b-rep-face-vertices ( b-rep selected -- vertices count indices )
    float-4-vector{ } clone :> vertices
    ushort-vector{ } clone :> indices

    0 b-rep faces>> [| count face |
        face selected face-selected? :> selected?
        face dup base-face>> eq? [
            face edge>> face-color
                selected? selected-face-color neutral-face-color ? v* :> color
            face triangulate-face seq>> :> triangles
            triangles members :> tri-vertices
            tri-vertices >index-hash :> vx-indices

            tri-vertices [
                position>> double-4>float-4 vertices push
                color vertices push
            ] each
            triangles [ vx-indices at count + indices push ] each

            count tri-vertices length +
        ] [ count ] if
    ] each :> total
    vertices float-4 >c-array underlying>>
    total
    indices ushort-array{ } like ;

: b-rep-edge-vertices ( b-rep -- vertices count )
    vertices>> [
        [
            position>> [ double-4>float-4 ] keep
            [ drop neutral-edge-color ]
            [ vertex-color rgba>float-4 ] 2bi
        ] data-map( object -- float-4[4] )
    ] [ length 2 * ] bi ; inline

GENERIC: selected-vectors ( object -- vectors )
M: object selected-vectors drop { } ;
M: double-4 selected-vectors 1array ;
M: sequence selected-vectors [ selected-vectors ] map concat ;

: selected-vertices ( selected -- vertices count )
    selected-vectors [
        [ [ double-4>float-4 ] [ vertex-color rgba>float-4 ] bi ]
        data-map( object -- float-4[2] )
    ] [ length ] bi ; inline

: edge-vertex-index ( e vertex-indices selected -- n selected? )
    [ dup vertex>> ] [ at 2 * ] [ swapd in? [ [ 1 + ] when ] keep ] tri* ;

:: b-rep-edge-index-array ( b-rep selected offset -- edge-indices )
    b-rep vertices>> >index-hash :> vertex-indices
    b-rep edges>> length <ushort-vector> :> edge-indices

    b-rep edges>> [| e |
        e opposite-edge>> :> o
        e vertex-indices selected edge-vertex-index [ offset + ] dip :> ( from e-selected? )
        o vertex-indices selected edge-vertex-index [ offset + ] dip :> ( to   o-selected? )

        from to < [ from edge-indices push to edge-indices push ] when
    ] each

    edge-indices ushort-array{ } like ;

:: make-b-rep-vertices ( b-rep selected -- vertices face-indices edge-indices point-indices )
    b-rep selected b-rep-face-vertices :> ( face-vertices face-count face-indices )
    b-rep b-rep-edge-vertices :> ( edge-vertices edge-count )
    selected selected-vertices :> ( sel-vertices sel-count )
    face-vertices face-count edge-vertices edge-count sel-vertices sel-count
    <b-rep-vertices> :> vertices

    vertices array>>

    face-indices

    b-rep selected vertices face-vertex-count>> b-rep-edge-index-array
    vertices

    [ face-vertex-count>> ]
    [ edge-vertex-count>> + dup ]
    [ point-vertex-count>> + ] tri
    [a..b) ushort >c-array ;

VERTEX-FORMAT: wire-vertex-format
    { "vertex"  float-components 3 f }
    { f         float-components 1 f }
    { "color"   float-components 4 f } ;

GLSL-SHADER-FILE: gml-viewer-vertex-shader vertex-shader "viewer.v.glsl"
GLSL-SHADER-FILE: gml-viewer-fragment-shader fragment-shader "viewer.f.glsl"
GLSL-PROGRAM: gml-viewer-program
    gml-viewer-vertex-shader gml-viewer-fragment-shader
    wire-vertex-format ;

TUPLE: gml-viewer-world < wasd-world
    { b-rep b-rep }
    selected
    program
    vertex-array
    face-indices edge-indices point-indices
    view-faces? view-edges?
    drag? ;

TYPED: refresh-b-rep-view ( world: gml-viewer-world -- )
    dup control-value >>b-rep
    dup vertex-array>> [ vertex-array-buffer dispose ] when*
    dup [ b-rep>> ] [ selected>> value>> ] bi make-b-rep-vertices {
        [
            static-upload draw-usage vertex-buffer byte-array>buffer
            over program>> <vertex-array> >>vertex-array
        ]
        [ >>face-indices ]
        [ >>edge-indices ]
        [ >>point-indices ]
    } spread
    drop ;

: viewable? ( gml-viewer-world -- ? )
    { [ b-rep>> ] [ program>> ] } 1&& ;

M: gml-viewer-world model-changed
    nip
    [ control-value ]
    [ b-rep<< ]
    [ dup viewable? [ refresh-b-rep-view ] [ drop ] if ] tri ;

: init-viewer-model ( gml-viewer-world -- )
    [ dup model>> add-connection ]
    [ dup selected>> add-connection ] bi ;

: reset-view ( gml-viewer-world -- )
    { 0.0 0.0 5.0 } 0.0 0.0 set-wasd-view drop ;

M: gml-viewer-world begin-game-world
    init-gpu
    t >>view-faces?
    t >>view-edges?
    T{ point-state { size 5.0 } } set-gpu-state
    dup reset-view
    gml-viewer-program <program-instance> >>program
    dup init-viewer-model
    refresh-b-rep-view ;

M: gml-viewer-world end-game-world
    [ dup selected>> remove-connection ]
    [ dup model>> remove-connection ] bi ;

M: gml-viewer-world draw-world*
    system-framebuffer {
        { default-attachment { 0.0 0.0 0.0 1.0 } }
        { depth-attachment 1.0 }
    } clear-framebuffer

    [
        dup view-faces?>> [
            T{ depth-state { comparison cmp-less } } set-gpu-state
            {
                { "primitive-mode" [ drop triangles-mode ] }
                { "indexes"        [ face-indices>> ] }
                { "uniforms"       [ <mvp-uniforms> ] }
                { "vertex-array"   [ vertex-array>> ] }
            } <render-set> render
            T{ depth-state { comparison f } } set-gpu-state
        ] [ drop ] if
    ] [
        dup view-edges?>> [
            {
                { "primitive-mode" [ drop lines-mode ] }
                { "indexes"        [ edge-indices>> ] }
                { "uniforms"       [ <mvp-uniforms> ] }
                { "vertex-array"   [ vertex-array>> ] }
            } <render-set> render
        ] [ drop ] if
    ] [
        {
            { "primitive-mode" [ drop points-mode ] }
            { "indexes"        [ point-indices>> ] }
            { "uniforms"       [ <mvp-uniforms> ] }
            { "vertex-array"   [ vertex-array>> ] }
        } <render-set> render
    ] tri ;

TYPED: rotate-view-mode ( world: gml-viewer-world -- )
    dup view-edges?>> [
        dup view-faces?>>
        [ f >>view-faces? ]
        [ f >>view-edges? t >>view-faces? ] if
    ] [ t >>view-edges? ] if drop ;

CONSTANT: edge-hitbox-radius 0.05

:: line-nearest-t ( p0 u q0 v -- tp tq )
    p0 q0 v- :> w0

    u u vdot :> a
    u v vdot :> b
    v v vdot :> c
    u w0 vdot :> d
    v w0 vdot :> e

    a c * b b * - :> denom

    b e * c d * - denom /f
    a e * b d * - denom /f ;

:: intersects-edge-node? ( source direction edge -- ? )
    edge vertex>> position>> double-4>float-4 :> edge-source
    edge opposite-edge>> vertex>> position>> double-4>float-4 edge-source v- :> edge-direction

    source direction edge-source edge-direction line-nearest-t :> ( ray-t edge-t )

    ray-t 0.0 >= edge-t 0.0 0.5 between? and [
        source direction ray-t v*n v+
        edge-source edge-direction edge-t v*n v+ v- norm
        edge-hitbox-radius <
    ] [ f ] if ;

: intersecting-edge-node ( source direction b-rep -- edge/f )
    edges>> [ intersects-edge-node? ] 2with find nip ;

: select-edge ( world -- )
    [ [ location>> ] [ hand-loc get wasd-pixel-ray ] bi ]
    [ b-rep>> intersecting-edge-node ]
    [ '[ _ [ selected>> push-model ] [ refresh-b-rep-view ] bi ] when* ] tri ;

gml-viewer-world H{
    { T{ button-up f f 1 } [ dup drag?>> [ drop ] [ select-edge ] if ] }
    { T{ drag f 1 } [ t >>drag? drop ] }
    { T{ key-down f f "RET" } [ reset-view ] }
    { T{ key-down f f "TAB" } [ rotate-view-mode ] }
} set-gestures

AFTER: gml-viewer-world tick-game-world
    dup drag?>> [
        read-mouse buttons>>
        ! FIXME: GTK Mouse buttons are an integer
        ! MacOSX mouse buttons are an array of bools
        dup integer? [ 0 bit? ] [ first ] if >>drag?
    ] when drop ;

M: gml-viewer-world wasd-mouse-scale drag?>> -1/600. 0.0 ? ;

: wrap-in-model ( object -- model )
    dup model? [ <model> ] unless ;
: wrap-in-growable-model ( object -- model )
    dup model? [
        dup growable? [ >vector ] unless
        <model>
    ] unless ;

: gml-viewer ( b-rep selection -- )
    [ wrap-in-model ] [ wrap-in-growable-model ] bi*
    '[
        f T{ game-attributes
            { world-class gml-viewer-world }
            { title "GML wireframe viewer" }
            { pixel-format-attributes {
                windowed
                double-buffered
                T{ depth-bits f 16 }
            } }
            { grab-input? f }
            { use-game-input? t }
            { use-audio-engine? f }
            { pref-dim { 1024 768 } }
            { tick-interval-nanos $[ 30 fps ] }
        } open-window*
        _ >>model
        _ >>selected
        drop
    ] with-ui ;
