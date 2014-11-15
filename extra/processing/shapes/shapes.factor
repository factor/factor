
USING: alien.c-types alien.data arrays colors grouping kernel
locals math math.vectors namespaces opengl opengl.gl opengl.glu
sequences sequences.generalizations shuffle ;
IN: processing.shapes

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: do-state ( mode quot -- ) swap glBegin call glEnd ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: fill-color
SYMBOL: stroke-color

T{ rgba f 0 0 0 1 } stroke-color set-global
T{ rgba f 1 1 1 1 } fill-color   set-global

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: fill-mode ( -- )
  GL_FRONT_AND_BACK GL_FILL glPolygonMode
  fill-color get gl-color ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: stroke-mode ( -- )
  GL_FRONT_AND_BACK GL_LINE glPolygonMode
  stroke-color get gl-color ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gl-vertex-2d ( vertex -- ) first2 glVertex2d ;

: gl-vertices-2d ( vertices -- ) [ gl-vertex-2d ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: point* ( x y    -- ) stroke-mode GL_POINTS [ glVertex2d     ] do-state ;
: point  ( point  -- ) stroke-mode GL_POINTS [ gl-vertex-2d   ] do-state ;
: points ( points -- ) stroke-mode GL_POINTS [ gl-vertices-2d ] do-state ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: line** ( x y x y -- )
  stroke-mode GL_LINES [ glVertex2d glVertex2d ] do-state ;

: line* ( a b -- ) stroke-mode GL_LINES [ [ gl-vertex-2d ] bi@ ] do-state ;

: lines ( seq -- ) stroke-mode GL_LINES [ gl-vertices-2d ] do-state ;

: line ( seq -- ) lines ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: line-strip ( seq -- ) stroke-mode GL_LINE_STRIP [ gl-vertices-2d ] do-state ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: triangles ( seq -- )
  [ fill-mode   GL_TRIANGLES [ gl-vertices-2d ] do-state ]
  [ stroke-mode GL_TRIANGLES [ gl-vertices-2d ] do-state ] bi ;

: triangle ( seq -- ) triangles ;

: triangle* ( a b c -- ) 3array triangles ;

: triangle** ( x y x y x y -- ) 6 narray 2 group triangles ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: polygon ( seq -- )
  [ fill-mode   GL_POLYGON [ gl-vertices-2d ] do-state ]
  [ stroke-mode GL_POLYGON [ gl-vertices-2d ] do-state ] bi ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: rectangle ( loc dim -- )
    loc first2 :> ( x y )
    dim first2 :> ( dx dy )

    x y 2array
    x dx + y 2array
    x y dy + 2array
    x dx + y dy + 2array
    4array
    polygon ;

: rectangle* ( x y width height -- ) [ 2array ] 2bi@ rectangle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gl-translate-2d ( pos -- ) first2 0 glTranslated ;

: gl-scale-2d ( xy -- ) first2 1 glScaled ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gl-ellipse ( center dim -- )
  glPushMatrix
    [ gl-translate-2d ] [ gl-scale-2d ] bi*
    gluNewQuadric
      dup 0 0.5 20 1 gluDisk
    gluDeleteQuadric
  glPopMatrix ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gl-get-line-width ( -- width )
  GL_LINE_WIDTH 0 double <ref> tuck glGetDoublev double deref ;

: ellipse ( center dim -- )
  GL_FRONT_AND_BACK GL_FILL glPolygonMode
  [ stroke-color get gl-color                                 gl-ellipse ]
  [ fill-color get gl-color gl-get-line-width 2 * dup 2array v- gl-ellipse ] 2bi ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: circle ( center size -- ) dup 2array ellipse ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

