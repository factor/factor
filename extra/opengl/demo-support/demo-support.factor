USING: arrays kernel math math.functions math.order math.vectors
namespaces opengl opengl.gl sequences ui ui.gadgets ui.gestures
ui.render accessors combinators ;
IN: opengl.demo-support

: FOV ( -- x ) 2.0 sqrt 1+ ; inline
CONSTANT: MOUSE-MOTION-SCALE 0.5
CONSTANT: KEY-ROTATE-STEP 10.0

SYMBOL: last-drag-loc

TUPLE: demo-gadget < gadget yaw pitch distance ;

: new-demo-gadget ( yaw pitch distance class -- gadget )
    new-gadget
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
    [ + ] with change-yaw relayout-1 ;

: pitch-demo-gadget ( pitch gadget -- )
    [ + ] with change-pitch relayout-1 ;

: zoom-demo-gadget ( distance gadget -- )
    [ + ] with change-distance relayout-1 ;

M: demo-gadget pref-dim* ( gadget -- dim )
    drop { 640 480 } ;

: -+ ( x -- -x x )
    [ neg ] keep ;

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
        [ [ 0.0 0.0 ] dip distance>> neg glTranslatef ]
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

: gl-vertex ( point -- )
    dup length {
        { 2 [ first2 glVertex2d ] }
        { 3 [ first3 glVertex3d ] }
        { 4 [ first4 glVertex4d ] }
    } case ;

: gl-normal ( normal -- ) first3 glNormal3d ;

: do-state ( mode quot -- )
    swap glBegin call glEnd ; inline

: rect-vertices ( lower-left upper-right -- )
    GL_QUADS [
        over first2 glVertex2d
        dup first pick second glVertex2d
        dup first2 glVertex2d
        swap first swap second glVertex2d
    ] do-state ;

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

