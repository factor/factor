
USING: kernel namespaces math opengl.gl opengl.glu ui ui.gadgets.slate
       random-weighted cfdg ;

IN: cfdg.models.sierpinski

: shape ( -- ) circle ;

! : sierpinski ( -- )
! iterate? [
!   shape
!   [ 0.6 s 5 r  0.2 b -1.5  y          0 x sierpinski ] do
!   [ 0.6 s 5 r -0.2 b  0.75 y -1.2990375 x sierpinski ] do
!   [ 0.6 s 5 r         0.75 y  1.2990375 x sierpinski ] do
! ] when ;

: sierpinski ( -- )
iterate? [
  shape
  [ -1.5 y          0 x 0.6 s 5 r  0.2 b sierpinski ] do
  [ 0.75 y -1.2990375 x 0.6 s 5 r -0.2 b sierpinski ] do
  [ 0.75 y  1.2990375 x 0.6 s 5 r        sierpinski ] do
] when ;

: top ( -- ) [ -13.5 r 0.5 b sierpinski ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init ( -- )
  [ ]           >background
  { -4 8 -4 8 } >viewport
  0.01          >threshold
  [ top ]       >start-shape ;

: run ( -- ) [ init ] cfdg-window. ;

MAIN: run