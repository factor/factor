
USING: kernel namespaces math opengl.gl opengl.glu ui ui.gadgets.slate
       random-weighted cfdg ;

IN: cfdg.models.snowflake

: spike ( -- )
iterate? [
  { { 1    [ square
      	     [ 0.95 y 0.97 s spike ] do ] }
    { 0.03 [ square
      	     [ 60 r spike ] do
	     [ -60 r spike ] do
	     [ 0.95 y 0.97 s spike ] do ] }
  } random-weighted* call
] when ;

: snowflake ( -- )
spike
[ 60 r spike ] do
[ 120 r spike ] do
[ 180 r spike ] do
[ 240 r spike ] do
[ 300 r spike ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: run ( -- )
{ -40 80 -40 80 } viewport set
0.1 threshold set
[ snowflake ] start-shape set
cfdg-window ;

MAIN: run

