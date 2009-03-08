
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
             [ 0.95 y 0.97 s spike ] do ] } }
  call-random-weighted
] when ;

: snowflake ( -- )
spike
[ 60 r spike ] do
[ 120 r spike ] do
[ 180 r spike ] do
[ 240 r spike ] do
[ 300 r spike ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init ( -- )
  [ ]               >background
  { -40 80 -40 80 } >viewport
  0.1               >threshold
  [ snowflake ]     >start-shape ;

: run ( -- ) [ init ] cfdg-window. ;

MAIN: run

