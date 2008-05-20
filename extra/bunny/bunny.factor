USING: alien alien.c-types arrays sequences math math.vectors
math.matrices math.parser io io.files kernel opengl opengl.gl
opengl.glu shuffle http.client vectors namespaces ui.gadgets
ui.gadgets.canvas ui.render ui splitting combinators tools.time
system combinators.lib float-arrays continuations
opengl.demo-support multiline ui.gestures bunny.fixed-pipeline
bunny.cel-shaded bunny.outlined bunny.model accessors destructors ;
IN: bunny

TUPLE: bunny-gadget model geom draw-seq draw-n ;

: <bunny-gadget> ( -- bunny-gadget )
    0.0 0.0 0.375 <demo-gadget>
    maybe-download read-model {
        set-delegate
        (>>model)
    } bunny-gadget construct ;

: bunny-gadget-draw ( gadget -- draw )
    { draw-n>> draw-seq>> }
    get-slots nth ;

: bunny-gadget-next-draw ( gadget -- )
    dup { draw-seq>> draw-n>> }
    get-slots
    1+ swap length mod
    >>draw-n relayout-1 ;

M: bunny-gadget graft* ( gadget -- )
    GL_DEPTH_TEST glEnable
    dup model>> <bunny-geom> >>geom
    dup
    [ <bunny-fixed-pipeline> ]
    [ <bunny-cel-shaded> ]
    [ <bunny-outlined> ] tri 3array
    sift >>draw-seq
    0 >>draw-n
    drop ;

M: bunny-gadget ungraft* ( gadget -- )
    [ geom>> [ dispose ] when* ]
    [ draw-seq>> [ [ dispose ] when* ] each ] bi ;

M: bunny-gadget draw-gadget* ( gadget -- )
    0.15 0.15 0.15 1.0 glClearColor
    GL_DEPTH_BUFFER_BIT GL_COLOR_BUFFER_BIT bitor glClear
    dup demo-gadget-set-matrices
    GL_MODELVIEW glMatrixMode
    0.02 -0.105 0.0 glTranslatef
    { geom>> bunny-gadget-draw } get-slots
    draw-bunny ;

M: bunny-gadget pref-dim* ( gadget -- dim )
    drop { 640 480 } ;
    
bunny-gadget H{
    { T{ key-down f f "TAB" } [ bunny-gadget-next-draw ] }
} set-gestures

: bunny-window ( -- )
    [ <bunny-gadget> "Bunny" open-window ] with-ui ;

MAIN: bunny-window
