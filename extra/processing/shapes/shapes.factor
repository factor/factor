USING: alien.c-types alien.data arrays colors grouping kernel
math math.constants math.vectors namespaces opengl
opengl.demo-support opengl.gl opengl.glu sequences
sequences.generalizations ui.render ;
IN: processing.shapes

SYMBOL: fill-color
SYMBOL: stroke-color

COLOR: black stroke-color set-global
COLOR: white fill-color set-global

: fill-mode ( -- )
    GL_FRONT_AND_BACK GL_FILL glPolygonMode
    fill-color get gl-color ;

: stroke-mode ( -- )
    GL_FRONT_AND_BACK GL_LINE glPolygonMode
    stroke-color get gl-color ;

: gl-vertex-2d ( vertex -- ) first2 glVertex2d ;

: gl-vertices-2d ( vertices -- ) [ gl-vertex-2d ] each ;

! GL3-compatible point drawing
: draw-point-gl3 ( point -- )
    stroke-color get gl-color
    gl3-point* ;

: draw-points-gl3 ( points -- )
    stroke-color get gl-color
    gl3-points* ;

: draw-point-legacy ( point -- )
    stroke-mode GL_POINTS [ gl-vertex-2d ] do-state ;

: draw-point* ( x y    -- ) stroke-mode GL_POINTS [ glVertex2d     ] do-state ;
: draw-point  ( point  -- )
    gl3-mode? get-global [ draw-point-gl3 ] [ draw-point-legacy ] if ;
: draw-points ( points -- )
    gl3-mode? get-global [ draw-points-gl3 ]
    [ stroke-mode GL_POINTS [ gl-vertices-2d ] do-state ] if ;

: draw-line** ( x y x y -- )
    stroke-mode GL_LINES [ glVertex2d glVertex2d ] do-state ;

: draw-line* ( a b -- ) stroke-mode GL_LINES [ [ gl-vertex-2d ] bi@ ] do-state ;

: draw-lines ( seq -- ) stroke-mode GL_LINES [ gl-vertices-2d ] do-state ;

: draw-line ( seq -- ) draw-lines ;

: line-strip ( seq -- ) stroke-mode GL_LINE_STRIP [ gl-vertices-2d ] do-state ;

: draw-triangles ( seq -- )
    [ fill-mode   GL_TRIANGLES [ gl-vertices-2d ] do-state ]
    [ stroke-mode GL_TRIANGLES [ gl-vertices-2d ] do-state ] bi ;

: draw-triangle ( seq -- ) draw-triangles ;

: draw-triangle* ( a b c -- ) 3array draw-triangles ;

: draw-triangle** ( x y x y x y -- ) 6 narray 2 group draw-triangles ;

: draw-polygon ( seq -- )
    [ fill-mode   GL_POLYGON [ gl-vertices-2d ] do-state ]
    [ stroke-mode GL_POLYGON [ gl-vertices-2d ] do-state ] bi ;

:: draw-rectangle ( loc dim -- )
    loc first2 :> ( x y )
    dim first2 :> ( dx dy )

    x y 2array
    x dx + y 2array
    x dx + y dy + 2array
    x y dy + 2array
    4array
    draw-polygon ;

: draw-rectangle* ( x y width height -- ) [ 2array ] 2bi@ draw-rectangle ;

: gl-translate-2d ( pos -- ) first2 0 glTranslated ;

: gl-scale-2d ( xy -- ) first2 1 glScaled ;

: gl-ellipse ( center dim -- )
    glPushMatrix
    [ gl-translate-2d ] [ gl-scale-2d ] bi*
    gluNewQuadric
    dup 0 0.5 20 1 gluDisk
    gluDeleteQuadric
    glPopMatrix ;

: gl-get-line-width ( -- width )
    GL_LINE_WIDTH 0 double <ref> tuck glGetDoublev double deref ;

! GL3-compatible ellipse/circle drawing
CONSTANT: circle-segments 20

:: draw-ellipse-gl3 ( center dim -- )
    ! Draw filled ellipse
    fill-color get gl-color
    center dim first 2 / circle-segments gl3-fill-circle*
    ! Draw outline
    stroke-color get gl-color
    center dim first 2 / gl-get-line-width - circle-segments gl3-circle* ;

: draw-ellipse-legacy ( center dim -- )
    GL_FRONT_AND_BACK GL_FILL glPolygonMode
    [ stroke-color get gl-color                                 gl-ellipse ]
    [ fill-color get gl-color gl-get-line-width 2 * dup 2array v- gl-ellipse ] 2bi ;

: draw-ellipse ( center dim -- )
    gl3-mode? get-global [ draw-ellipse-gl3 ] [ draw-ellipse-legacy ] if ;

: draw-circle ( center size -- ) dup 2array draw-ellipse ;
