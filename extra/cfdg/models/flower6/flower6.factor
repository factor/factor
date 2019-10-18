
USING: kernel namespaces sequences math
       opengl.gl opengl.glu ui ui.gadgets.slate
       random-weighted cfdg ;

IN: cfdg.models.flower6

: petal6 ( -- )
iterate? [
  [ 1 0.001 s* square ] do
  [ -0.5 x 0.01 s -1 b circle ] do
  [ 0.5 x 120.21 r 0.996 s 0.5 x 0.005 b petal6 ] do
] when ;

: flower6 ( -- )
12 [ [ [ 30 r ] times petal6 ] do ] each
12 [ [ [ 30 r ] times 90 flip petal6 ] do ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: run ( -- )
[ ] >background
{ -1 2 -1 2 } viewport set
0.01 threshold set
[ flower6 ] start-shape set
cfdg-window ;

MAIN: run

