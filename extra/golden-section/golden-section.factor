
USING: kernel namespaces math math.constants math.functions arrays sequences
       opengl opengl.gl opengl.glu ui ui.render ui.gadgets ui.gadgets.theme
       ui.gadgets.slate colors accessors combinators.cleave ;

IN: golden-section

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: disk ( radius center -- )
  glPushMatrix
  gl-translate
  dup 0 glScalef
  gluNewQuadric [ 0 1 20 20 gluDisk ] [ gluDeleteQuadric ] bi
  glPopMatrix ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! omega(i) = 2*pi*i*(phi-1)

! x(i) = 0.5*i*cos(omega(i))
! y(i) = 0.5*i*sin(omega(i))

! radius(i) = 10*sin((pi*i)/720)

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: omega ( i -- omega ) phi 1- * 2 * pi * ;

: x ( i -- x ) [ omega cos ] [ 0.5 * ] bi * ;
: y ( i -- y ) [ omega sin ] [ 0.5 * ] bi * ;

: center ( i -- point ) { x y } 1arr ;

: radius ( i -- radius ) pi * 720 / sin 10 * ;

: color ( i -- color ) 360.0 / dup 0.25 1 4array ;

: rim   ( i -- ) [ drop black gl-color ] [ radius 1.5 * ] [ center ] tri disk ;
: inner ( i -- ) [      color gl-color ] [ radius       ] [ center ] tri disk ;

: dot ( i -- ) [ rim ] [ inner ] bi ;

: golden-section ( -- ) 720 [ dot ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: display ( -- )
  GL_PROJECTION glMatrixMode
  glLoadIdentity
  -400 400 -400 400 -1 1 glOrtho
  GL_MODELVIEW glMatrixMode
  glLoadIdentity
  golden-section ;

: golden-section-window ( -- )
    [
      [ display ] <slate>
        { 600 600 } >>pdim
      "Golden Section" open-window
    ]
  with-ui ;

MAIN: golden-section-window
