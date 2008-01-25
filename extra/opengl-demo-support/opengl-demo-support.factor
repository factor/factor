USING: arrays combinators.lib kernel math math.functions math.vectors namespaces
       opengl opengl.gl sequences ui ui.gadgets ui.gestures ui.render ;
IN: opengl-demo-support

: NEAR-PLANE 1.0 64.0 / ; inline
: FAR-PLANE 4.0 ; inline
: FOV 2.0 sqrt 1+ ; inline
: MOUSE-MOTION-SCALE 0.5 ; inline
: MOUSE-DISTANCE-SCALE 1.0 64.0 / ; inline
: KEY-ROTATE-STEP 1.0 ; inline
: KEY-DISTANCE-STEP 1.0 64.0 / ; inline
: DIMS { 640 480 } ; inline

: FOV-RATIO ( -- fov ) DIMS dup first2 min v/n ;

SYMBOL: last-drag-loc

TUPLE: demo-gadget yaw pitch distance ;

: <demo-gadget> ( yaw pitch distance -- gadget )
    demo-gadget construct-gadget 
    [ { set-demo-gadget-yaw set-demo-gadget-pitch set-demo-gadget-distance } set-slots ] keep ;

: yaw-demo-gadget ( yaw gadget -- )
    [ [ demo-gadget-yaw + ] keep set-demo-gadget-yaw ] keep relayout-1 ;

: pitch-demo-gadget ( pitch gadget -- )
    [ [ demo-gadget-pitch + ] keep set-demo-gadget-pitch ] keep relayout-1 ;

: zoom-demo-gadget ( distance gadget -- )
    [ [ demo-gadget-distance + ] keep set-demo-gadget-distance ] keep relayout-1 ;

M: demo-gadget pref-dim* ( gadget -- dim )
    drop DIMS ;

: -+ ( x -- -x x )
    dup neg swap ;

: demo-gadget-frustum ( -- -x x -y y near far )
    FOV-RATIO NEAR-PLANE FOV / v*n
    first2 [ -+ ] 2apply NEAR-PLANE FAR-PLANE ;

: demo-gadget-set-matrices ( gadget -- )
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    demo-gadget-frustum glFrustum
    GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    { [ >r 0.0 0.0 r> demo-gadget-distance neg glTranslatef ]
      [ demo-gadget-pitch 1.0 0.0 0.0 glRotatef ]
      [ demo-gadget-yaw   0.0 1.0 0.0 glRotatef ] } call-with ;

: reset-last-drag-rel ( -- )
    { 0 0 } last-drag-loc set ;
: last-drag-rel ( -- rel )
    drag-loc [ last-drag-loc get v- ] keep last-drag-loc set ;

: drag-yaw-pitch ( -- yaw pitch )
    last-drag-rel MOUSE-MOTION-SCALE v*n first2 ;

demo-gadget H{
    { T{ key-down f f "LEFT"  } [ KEY-ROTATE-STEP neg swap yaw-demo-gadget ] }
    { T{ key-down f f "RIGHT" } [ KEY-ROTATE-STEP     swap yaw-demo-gadget ] }
    { T{ key-down f f "DOWN"  } [ KEY-ROTATE-STEP neg swap pitch-demo-gadget ] }
    { T{ key-down f f "UP"    } [ KEY-ROTATE-STEP     swap pitch-demo-gadget ] }
    { T{ key-down f f "="     } [ KEY-DISTANCE-STEP neg swap zoom-demo-gadget ] }
    { T{ key-down f f "-"     } [ KEY-DISTANCE-STEP     swap zoom-demo-gadget ] }
    
    { T{ button-down f f 1 }    [ drop reset-last-drag-rel ] }
    { T{ drag f 1 }             [ drag-yaw-pitch rot [ pitch-demo-gadget ] keep yaw-demo-gadget ] }
    { T{ mouse-scroll }         [ scroll-direction get second MOUSE-DISTANCE-SCALE * swap zoom-demo-gadget ] }
} set-gestures

