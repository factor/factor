! From http://www.ffconsultancy.com/ocaml/maze/index.html
USING: accessors arrays kernel math math.order math.vectors
namespaces opengl.demo-support opengl.gl random sequences ui
ui.gadgets ui.gadgets.canvas ui.gestures ui.render ;
IN: maze

CONSTANT: line-width 8

SYMBOL: visited

: unvisited? ( cell -- ? ) first2 visited get ?nth ?nth ;

: visit ( cell -- ) f swap first2 visited get ?nth ?set-nth ;

: choices ( cell -- seq )
    { { -1 0 } { 1 0 } { 0 -1 } { 0 1 } }
    [ v+ ] with map
    [ unvisited? ] filter ;

: random-neighbor ( cell -- newcell ) choices random ;

: vertex ( pair -- )
    first2 [ 0.5 + line-width * ] bi@ glVertex2d ;

: (draw-maze) ( cell -- )
    dup vertex
    glEnd
    GL_POINTS [ dup vertex ] do-state
    GL_LINE_STRIP glBegin
    dup vertex
    dup visit
    dup random-neighbor [
        (draw-maze) (draw-maze)
    ] [
        drop
        glEnd
        GL_LINE_STRIP glBegin
    ] if* ;

: draw-maze ( n -- )
    line-width 2 - glLineWidth
    line-width 2 - glPointSize
    1.0 1.0 1.0 1.0 glColor4d
    dup '[ _ t <array> ] replicate visited set
    GL_LINE_STRIP [
        { 0 0 } dup vertex (draw-maze)
    ] do-state ;

TUPLE: maze < canvas ;

: <maze> ( -- gadget ) maze new-canvas ;

: n ( gadget -- n ) dim>> first2 min line-width /i ;

M: maze layout* delete-canvas-dlist ;

M: maze draw-gadget* [ n draw-maze ] draw-canvas ;

M: maze pref-dim* drop { 400 400 } ;

M: maze handle-gesture
    over T{ button-down { # 1 } } =
    [ nip relayout f ] [ call-next-method ] if ;

MAIN-WINDOW: maze-window { { title "Maze" } }
    <maze> >>gadgets ;
