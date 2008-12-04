
USING: kernel namespaces math math.constants math.functions math.order
       arrays sequences
       opengl opengl.gl opengl.glu ui ui.render ui.gadgets ui.gadgets.theme
       ui.gadgets.cartesian colors accessors combinators.cleave
       processing.shapes ;

IN: golden-section

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

: color ( i -- i ) dup 360.0 / dup 0.25 1 rgba boa >fill-color ;

: line-width ( i -- i ) dup radius 0.5 * 1 max glLineWidth ;

: draw ( i -- ) [ center ] [ radius 1.5 * 2 * ] bi circle ;

: dot ( i -- ) color line-width draw ;

: golden-section ( -- ) 720 [ dot ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: <golden-section> ( -- gadget )
  <cartesian>
    {  600 600 }       >>pdim
    { -400 400 }       x-range
    { -400 400 }       y-range
    [ golden-section ] >>action ;

: golden-section-window ( -- )
  [ <golden-section> "Golden Section" open-window ] with-ui ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: golden-section-window
