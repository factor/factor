
USING: kernel namespaces sequences math
       opengl.gl opengl.glu ui ui.gadgets.slate
       random-weighted cfdg ;

IN: cfdg.models.chiaroscuro

DEFER: white

: black ( -- ) iterate? [
{ { 60 [ [ 0.6 s circle ] do
       	 [ 0.1 x 5 r 0.99 s -0.01 b -0.01 a black ] do ] }
  { 1 [ white black ] } }
random-weighted* call
] when ;

: white ( -- ) iterate? [
{ { 60 [ [ 0.6 s circle ] do
       	 [ 0.1 x -5 r 0.99 s 0.01 b -0.01 a white ] do ] }
  { 1 [ black white ] } }
random-weighted* call
] when ;

: chiaroscuro ( -- ) [ 0.5 b black ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: run ( -- )
[ -0.5 b ] >background
{ -3 6 -2 6 } viewport set
0.01 threshold set
[ chiaroscuro ] start-shape set
cfdg-window ;

MAIN: run
