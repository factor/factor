USING: alien alien.c-types arrays sequences math
math.vectors math.matrices math.parser io io.files kernel opengl
opengl.gl opengl.glu shuffle http.client vectors timers
namespaces ui.gadgets ui.gadgets.canvas ui.render ui splitting
combinators tools.time system combinators.lib combinators.cleave
float-arrays continuations opengl.demo-support multiline
ui.gestures
bunny.fixed-pipeline bunny.cel-shaded bunny.outlined bunny.model ;
IN: bunny

TUPLE: bunny-gadget model geom draw-seq draw-n ;

: <bunny-gadget> ( -- bunny-gadget )
    0.0 0.0 0.375 <demo-gadget>
    maybe-download read-model {
        set-delegate
        set-bunny-gadget-model
    } bunny-gadget construct ;

: bunny-gadget-draw ( gadget -- draw )
    { bunny-gadget-draw-n bunny-gadget-draw-seq }
    get-slots nth ;

: bunny-gadget-next-draw ( gadget -- )
    dup { bunny-gadget-draw-seq bunny-gadget-draw-n }
    get-slots
    1+ swap length mod
    swap [ set-bunny-gadget-draw-n ] keep relayout-1 ;

M: bunny-gadget graft* ( gadget -- )
    GL_DEPTH_TEST glEnable
    dup bunny-gadget-model <bunny-geom>
    over {
        [ <bunny-fixed-pipeline> ]
        [ <bunny-cel-shaded> ]
        [ <bunny-outlined> ]
    } map-call-with [ ] subset
    0
    roll {
        set-bunny-gadget-geom
        set-bunny-gadget-draw-seq
        set-bunny-gadget-draw-n
    } set-slots ;

M: bunny-gadget ungraft* ( gadget -- )
    { bunny-gadget-geom bunny-gadget-draw-seq } get-slots
    [ [ dispose ] when* ] each
    [ dispose ] when* ;

M: bunny-gadget draw-gadget* ( gadget -- )
    0.15 0.15 0.15 1.0 glClearColor
    GL_DEPTH_BUFFER_BIT GL_COLOR_BUFFER_BIT bitor glClear
    dup demo-gadget-set-matrices
    GL_MODELVIEW glMatrixMode
    0.0 -0.12 0.0 glTranslatef
    { bunny-gadget-geom bunny-gadget-draw } get-slots
    draw-bunny ;

M: bunny-gadget pref-dim* ( gadget -- dim )
    drop { 640 480 } ;
    
bunny-gadget H{
    { T{ key-down f f "TAB" } [ bunny-gadget-next-draw ] }
} set-gestures

: bunny-window ( -- )
    [ <bunny-gadget> "Bunny" open-window ] with-ui ;

MAIN: bunny-window
