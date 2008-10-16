USING: accessors arrays bunny.cel-shaded bunny.fixed-pipeline
bunny.model bunny.outlined destructors kernel math opengl.demo-support
opengl.gl sequences ui ui.gadgets ui.gadgets.worlds ui.gestures
ui.render words ;
IN: bunny

TUPLE: bunny-gadget < demo-gadget model-triangles geom draw-seq draw-n ;

: <bunny-gadget> ( -- bunny-gadget )
    0.0 0.0 0.375 bunny-gadget new-demo-gadget
    maybe-download read-model >>model-triangles ;

: bunny-gadget-draw ( gadget -- draw )
    [ draw-n>> ] [ draw-seq>> ] bi nth ;

: bunny-gadget-next-draw ( gadget -- )
    dup [ draw-seq>> ] [ draw-n>> ] bi
    1+ swap length mod
    >>draw-n relayout-1 ;

M: bunny-gadget graft* ( gadget -- )
    dup find-gl-context
    GL_DEPTH_TEST glEnable
    dup model-triangles>> <bunny-geom> >>geom
    dup
    [ <bunny-fixed-pipeline> ]
    [ <bunny-cel-shaded> ]
    [ <bunny-outlined> ] tri 3array
    sift >>draw-seq
    0 >>draw-n
    drop ;

M: bunny-gadget ungraft* ( gadget -- )
    dup find-gl-context
    [ geom>> [ dispose ] when* ]
    [ draw-seq>> [ [ dispose ] when* ] each ] bi ;

M: bunny-gadget draw-gadget* ( gadget -- )
    dup draw-seq>> empty? [ drop ] [
        0.15 0.15 0.15 1.0 glClearColor
        GL_DEPTH_BUFFER_BIT GL_COLOR_BUFFER_BIT bitor glClear
        dup demo-gadget-set-matrices
        GL_MODELVIEW glMatrixMode
        0.02 -0.105 0.0 glTranslatef
        [ geom>> ] [ bunny-gadget-draw ] bi draw-bunny
    ] if ;

M: bunny-gadget pref-dim* ( gadget -- dim )
    drop { 640 480 } ;
    
bunny-gadget H{
    { T{ key-down f f "TAB" } [ bunny-gadget-next-draw ] }
} set-gestures

: bunny-window ( -- )
    [ <bunny-gadget> "Bunny" open-window ] with-ui ;

MAIN: bunny-window
