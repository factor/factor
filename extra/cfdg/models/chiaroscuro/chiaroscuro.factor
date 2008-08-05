
USING: kernel namespaces sequences math
       opengl.gl opengl.glu ui ui.gadgets.slate
       random-weighted cfdg ;

IN: cfdg.models.chiaroscuro

DEFER: white

: black ( -- ) iterate? [
  { { 60 [ [ 0.6 s circle ] do
           [ 0.1 x 5 r 0.99 s -0.01 b -0.01 a black ] do ] }
    { 1 [ white black ] } }
  call-random-weighted
] when ;

: white ( -- ) iterate? [
  { { 60 [
           [ 0.6 s circle ] do
           [ 0.1 x -5 r 0.99 s 0.01 b -0.01 a white ] do
         ] }
    { 1 [
          black white
        ] } }
  call-random-weighted
] when ;

: chiaroscuro ( -- ) [ 0.5 b black ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init ( -- )
  [ -0.5 b ]      >background
  { -3 6 -2 6 }   >viewport
  0.01            >threshold
  [ chiaroscuro ] >start-shape ;

: run ( -- ) [ init ] cfdg-window. ;

MAIN: run
