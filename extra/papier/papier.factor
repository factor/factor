! (c)2010 Joe Groff bsd license
USING: accessors alien.c-types alien.data.map arrays assocs
combinators fry game.input game.input.scancodes game.loop
game.worlds gpu gpu.buffers gpu.framebuffers gpu.render
gpu.shaders gpu.state gpu.textures hashtables images kernel
literals math math.matrices.simd math.order math.vectors
math.vectors.simd papier.map papier.render papier.sprites
sequences sorting typed ui ui.gadgets ui.gadgets.worlds
ui.gestures ui.pixel-formats math.functions ;
IN: papier

CONSTANT: fov 0.7
CONSTANT: near-plane 0.25
CONSTANT: far-plane 1024.0
CONSTANT: move-rate 0.05
CONSTANT: eye float-4{ 0.0 2.5 7.0 0.0 }

CONSTANT:  1/√2 $[ 0.5 sqrt     ]
CONSTANT: -1/√2 $[ 0.5 sqrt neg ]

TUPLE: papier-world < game-world
    { slabs array }
    { slabs-by-name hashtable }
    { slab-images hashtable }
    { atlas image }
    { uniforms papier-uniforms }
    { renderer papier-renderer } ;

: load-slabs ( -- slabs )
    <sprite>
        "backdrop" >>name
        { "backdrop.png" } >>images
        0 >>frame
        float-4{ 0 9.0 -2.0 1 } >>center
        float-4{ 10 10 1 1 } >>size
        float-4{ 1 0 0 0 } >>orient
        float-4{ 1 1 1 1 } >>color
        { { T{ animation-frame f  0 1 } } } swap set-up-sprite
        dup update-slab-matrix

    <sprite>
        "ground" >>name
        { "ground.png" } >>images
        0 >>frame
        float-4{ 0 -1 0 1 } >>center
        float-4{ 10 2 2 1 } >>size
        float-4{ $ 1/√2 $ 1/√2 0 0 } >>orient
        float-4{ 1 1 1 1 } >>color
        { { T{ animation-frame f  0 1 } } } swap set-up-sprite
        dup update-slab-matrix

    <sprite>
        "cat" >>name
        {
            "dancing-cat001.png"
            "dancing-cat002.png"
            "dancing-cat003.png"
            "dancing-cat004.png"
            "dancing-cat005.png"
            "dancing-cat006.png"
            "dancing-cat007.png"
            "dancing-cat008.png"
            "dancing-cat009.png"
            "dancing-cat010.png"
            "dancing-cat011.png"
            "dancing-cat012.png"
        } >>images
        0 >>frame
        float-4{ 3 -0.25 -0.1 1 } >>center
        float-4{ 0.75 0.75 1.0 1.0 } >>size
        float-4{ 1 0 0 0 } >>orient
        float-4{ 1 1 1 1 } >>color
        {
            {
                T{ animation-frame f  0 2 }
                T{ animation-frame f  1 2 }
                T{ animation-frame f  2 2 }
                T{ animation-frame f  3 2 }
                T{ animation-frame f  4 2 }
                T{ animation-frame f  5 2 }
                T{ animation-frame f  6 2 }
                T{ animation-frame f  7 2 }
                T{ animation-frame f  8 2 }
                T{ animation-frame f  9 2 }
                T{ animation-frame f 10 2 }
                T{ animation-frame f 11 2 }
            }
        } swap set-up-sprite
        dup update-slab-matrix

    <sprite>
        "marco" >>name
        {
            "marco-still001.png"
            "marco-walk001.png"
            "marco-walk002.png"
            "marco-walk003.png"
            "marco-walk004.png"
            "marco-walk005.png"
            "marco-walk006.png"
            "marco-walk007.png"
            "marco-walk008.png"
            "marco-walk009.png"
            "marco-walk010.png"
            "marco-walk011.png"
            "marco-walk012.png"
            "marco-walk013.png"
            "marco-walk014.png"
        } >>images
        0 >>frame
        float-4{ -3 0 0 1 } >>center
        float-4{ 0.75 1.0 1.0 1.0 } >>size
        float-4{ 1 0 0 0 } >>orient
        float-4{ 1 1 1 1 } >>color
        {
            {
                T{ animation-frame f  0 1 }
            }
            {
                T{ animation-frame f  3 2 }
                T{ animation-frame f  4 2 }
                T{ animation-frame f  5 2 }
                T{ animation-frame f  6 2 }
                T{ animation-frame f  7 2 }
                T{ animation-frame f  8 2 }
                T{ animation-frame f  9 2 }
                T{ animation-frame f 10 2 }
                T{ animation-frame f 11 2 }
                T{ animation-frame f 12 2 }
                T{ animation-frame f 13 2 }
                T{ animation-frame f 14 2 }
                T{ animation-frame f  1 2 }
                T{ animation-frame f  2 2 }
            }
        } swap set-up-sprite
        dup update-slab-matrix

    4array ;

: load-images ( -- images atlas )
    "vocab:papier/_resources" load-papier-images ;

TYPED: prepare-world-slabs ( world: papier-world -- )
    [ dup slabs>> slabs-by-name >>slabs-by-name drop ]
    [ [ slabs>> ] [ slab-images>> ] bi update-slabs-for-atlas ]
    [ [ uniforms>> atlas>> 0 ] [ atlas>> ] bi allocate-texture-image ] tri ;

: dim4 ( world -- dim ) dim>> first2 0 0 float-4-boa ; inline

M: papier-world begin-game-world
    init-gpu
    set-papier-state

    <papier-renderer> >>renderer
    load-slabs >>slabs
    load-images [ >>slab-images ] [ >>atlas ] bi*

    papier-uniforms new
        over dim4 fov near-plane far-plane <p-matrix> >>p_matrix
        eye >>eye
        RGBA ubyte-components T{ texture-parameters
            { min-mipmap-filter f }
        } <texture-2d> >>atlas
    >>uniforms
    
    prepare-world-slabs ;

: move-eye ( world amount -- )
    [ uniforms>> ] dip '[ _ v+ ] change-eye drop ; inline

: keyboard-input ( papier-world -- movement/f face/f )
    read-keyboard keys>> {
        { [ key-left-arrow  over nth ] [ 2drop float-4{ $ move-rate 0 0 0 } vneg float-4{ 0 0 1 0 } ] }
        { [ key-right-arrow over nth ] [ 2drop float-4{ $ move-rate 0 0 0 }      float-4{ 1 0 0 0 } ] }
        { [ key-escape      over nth ] [ drop close-window f f ] }
        [ 2drop f f ]
    } cond ;

: update-slabs ( slabs -- )
    [ inc-sprite drop ] each ;

: move-player ( world move face -- )
    [ slabs-by-name>> "marco" swap at dup animations>> second switch-animation ] 2dip
    [ '[ _ v+ ] change-center ] [ >>orient ] bi* update-slab-matrix ;

: stop-player ( world -- )
    slabs-by-name>> "marco" swap at dup animations>> first switch-animation drop ;

M: papier-world tick-game-world
    dup slabs>> update-slabs
    dup focused?>> [
        dup keyboard-input
        [ move-player ]
        [ drop stop-player ] if*
    ] [ drop ] if ;

M: papier-world draw-world*
    [ renderer>> ] [ uniforms>> ] [ slabs>> ] tri draw-slabs ;

M: papier-world resize-world
    [ uniforms>> ]
    [ dim4 fov near-plane far-plane <p-matrix> ] bi
    >>p_matrix drop ;

GAME: papier-game {
        { world-class papier-world }
        { title "Papier" }
        { pixel-format-attributes {
            windowed
            double-buffered
            T{ depth-bits { value 24 } }
        } }
        { use-game-input? t }
        { pref-dim { 1024 768 } }
        { tick-interval-nanos $[ 24 fps ] }
    } ;
