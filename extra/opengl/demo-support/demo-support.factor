USING: arrays kernel math math.functions math.order math.vectors
namespaces opengl opengl.gl sequences ui ui.gadgets ui.gestures
ui.gadgets.worlds ui.render accessors combinators ;
IN: opengl.demo-support

: FOV ( -- x ) 2.0 sqrt 1+ ; inline
CONSTANT: MOUSE-MOTION-SCALE 0.5
CONSTANT: KEY-ROTATE-STEP 10.0

SYMBOL: last-drag-loc

TUPLE: demo-world < world yaw pitch distance ;

: set-demo-orientation ( world yaw pitch distance -- world )
    [ >>yaw ] [ >>pitch ] [ >>distance ] tri* ;

GENERIC: far-plane ( gadget -- z )
GENERIC: near-plane ( gadget -- z )
GENERIC: distance-step ( gadget -- dz )

M: demo-world far-plane ( gadget -- z )
    drop 4.0 ;
M: demo-world near-plane ( gadget -- z )
    drop 1.0 64.0 / ;
M: demo-world distance-step ( gadget -- dz )
    drop 1.0 64.0 / ;

: fov-ratio ( gadget -- fov ) dim>> dup first2 min v/n ;

: yaw-demo-world ( yaw gadget -- )
    [ + ] with change-yaw relayout-1 ;

: pitch-demo-world ( pitch gadget -- )
    [ + ] with change-pitch relayout-1 ;

: zoom-demo-world ( distance gadget -- )
    [ + ] with change-distance relayout-1 ;

M: demo-world focusable-child* ( world -- gadget )
    drop t ;

M: demo-world pref-dim* ( gadget -- dim )
    drop { 640 480 } ;

: -+ ( x -- -x x )
    [ neg ] keep ;

: demo-world-frustum ( world -- -x x -y y near far )
    [ near-plane ] [ far-plane ] [ fov-ratio ] tri [
        nip swap FOV / v*n
        first2 [ -+ ] bi@
    ] 3keep drop ;

M: demo-world resize-world
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    [ [ 0 0 ] dip dim>> first2 glViewport ]
    [ demo-world-frustum glFrustum ] bi ;

: demo-world-set-matrix ( gadget -- )
    GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    [ [ 0.0 0.0 ] dip distance>> neg glTranslatef ]
    [ pitch>> 1.0 0.0 0.0 glRotatef ]
    [ yaw>>   0.0 1.0 0.0 glRotatef ]
    tri ;

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

demo-world H{
    { T{ key-down f f "LEFT"  } [ KEY-ROTATE-STEP neg swap yaw-demo-world ] }
    { T{ key-down f f "RIGHT" } [ KEY-ROTATE-STEP     swap yaw-demo-world ] }
    { T{ key-down f f "DOWN"  } [ KEY-ROTATE-STEP neg swap pitch-demo-world ] }
    { T{ key-down f f "UP"    } [ KEY-ROTATE-STEP     swap pitch-demo-world ] }
    { T{ key-down f f "="     } [ dup distance-step neg swap zoom-demo-world ] }
    { T{ key-down f f "-"     } [ dup distance-step     swap zoom-demo-world ] }
    
    { T{ button-down f f 1 }    [ drop reset-last-drag-rel ] }
    { T{ drag f 1 }             [ drag-yaw-pitch rot [ pitch-demo-world ] keep yaw-demo-world ] }
    { mouse-scroll              [ scroll-direction get second over distance-step * swap zoom-demo-world ] }
} set-gestures

