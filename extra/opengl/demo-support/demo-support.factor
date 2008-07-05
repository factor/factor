USING: arrays kernel math math.functions
math.order math.vectors namespaces opengl opengl.gl sequences ui
ui.gadgets ui.gestures ui.render accessors ;
IN: opengl.demo-support

: FOV 2.0 sqrt 1+ ; inline
: MOUSE-MOTION-SCALE 0.5 ; inline
: KEY-ROTATE-STEP 1.0 ; inline

SYMBOL: last-drag-loc

TUPLE: demo-gadget yaw pitch distance ;

: <demo-gadget> ( yaw pitch distance -- gadget )
    demo-gadget construct-gadget
        swap >>distance
        swap >>pitch
        swap >>yaw ;

GENERIC: far-plane ( gadget -- z )
GENERIC: near-plane ( gadget -- z )
GENERIC: distance-step ( gadget -- dz )

M: demo-gadget far-plane ( gadget -- z )
    drop 4.0 ;
M: demo-gadget near-plane ( gadget -- z )
    drop 1.0 64.0 / ;
M: demo-gadget distance-step ( gadget -- dz )
    drop 1.0 64.0 / ;

: fov-ratio ( gadget -- fov ) dim>> dup first2 min v/n ;

: yaw-demo-gadget ( yaw gadget -- )
    [ [ demo-gadget-yaw + ] keep set-demo-gadget-yaw ] keep relayout-1 ;

: pitch-demo-gadget ( pitch gadget -- )
    [ [ demo-gadget-pitch + ] keep set-demo-gadget-pitch ] keep relayout-1 ;

: zoom-demo-gadget ( distance gadget -- )
    [ [ demo-gadget-distance + ] keep set-demo-gadget-distance ] keep relayout-1 ;

M: demo-gadget pref-dim* ( gadget -- dim )
    drop { 640 480 } ;

: -+ ( x -- -x x )
    dup neg swap ;

: demo-gadget-frustum ( gadget -- -x x -y y near far )
    [ near-plane ] [ far-plane ] [ fov-ratio ] tri [
        nip swap FOV / v*n
        first2 [ -+ ] bi@
    ] 3keep drop ;

: demo-gadget-set-matrices ( gadget -- )
    GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
    [
        GL_PROJECTION glMatrixMode
        glLoadIdentity
        demo-gadget-frustum glFrustum
    ] [
        GL_MODELVIEW glMatrixMode
        glLoadIdentity
        [ >r 0.0 0.0 r> distance>> neg glTranslatef ]
        [ pitch>> 1.0 0.0 0.0 glRotatef ]
        [ yaw>>   0.0 1.0 0.0 glRotatef ]
        tri
    ] bi ;

: reset-last-drag-rel ( -- )
    { 0 0 } last-drag-loc set-global ;
: last-drag-rel ( -- rel )
    drag-loc [ last-drag-loc get v- ] keep last-drag-loc set-global ;

: drag-yaw-pitch ( -- yaw pitch )
    last-drag-rel MOUSE-MOTION-SCALE v*n first2 ;

demo-gadget H{
    { T{ key-down f f "LEFT"  } [ KEY-ROTATE-STEP neg swap yaw-demo-gadget ] }
    { T{ key-down f f "RIGHT" } [ KEY-ROTATE-STEP     swap yaw-demo-gadget ] }
    { T{ key-down f f "DOWN"  } [ KEY-ROTATE-STEP neg swap pitch-demo-gadget ] }
    { T{ key-down f f "UP"    } [ KEY-ROTATE-STEP     swap pitch-demo-gadget ] }
    { T{ key-down f f "="     } [ dup distance-step neg swap zoom-demo-gadget ] }
    { T{ key-down f f "-"     } [ dup distance-step     swap zoom-demo-gadget ] }
    
    { T{ button-down f f 1 }    [ drop reset-last-drag-rel ] }
    { T{ drag f 1 }             [ drag-yaw-pitch rot [ pitch-demo-gadget ] keep yaw-demo-gadget ] }
    { T{ mouse-scroll }         [ scroll-direction get second over distance-step * swap zoom-demo-gadget ] }
} set-gestures

