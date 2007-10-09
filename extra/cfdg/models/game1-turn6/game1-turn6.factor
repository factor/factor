
USING: kernel namespaces math opengl.gl opengl.glu ui ui.gadgets.slate
       mortar random-weighted cfdg ;

IN: cfdg.models.game1-turn6

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: f-triangles ( -- ) iterate? [
[ 0.1 x 0.1 y -0.33 alpha 20 hue 0.7 sat 0.8 b triangle ] do
[ 10 hue 0.9 sat 0.33 b triangle ] do
[ 0.9 s 10 hue 0.5 sat 1 b triangle ] do
[ 0.8 s 5 r f-triangles ] do
] when ;

: f-squares ( -- ) iterate? [
[ 0.1 x 0.1 y -0.33 alpha 250 hue 0.7 sat 0.8 b square ] do
[ 220 hue 0.9 sat 0.33 b square ] do
[ 0.9 s 220 hue 0.25 sat 1 b square ] do
[ 0.8 s 5 r f-squares ] do
] when ;

DEFER: start

: spiral ( -- ) iterate? [
  { { 1 [ f-squares
      	  [ 0.5 x 0.5 y 45 r f-triangles ] do
	  [ 1 y 25 r 0.9 s spiral ] do ] }
    { 0.022 [ [ 90 flip 50 hue start ] do ] } }
  call-random-weighted
] when ;

: start ( -- )
  [       spiral ] do
  [ 120 r spiral ] do
  [ 240 r spiral ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: run ( -- )
[ 66 hue 0.4 sat 0.5 b ] >background
{ -5 10 -5 10 } viewport set
0.001 >threshold
[ start ] >start-shape
cfdg-window ;

MAIN: run