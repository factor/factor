
USING: kernel namespaces math random opengl.gl opengl.glu ui ui.gadgets.slate
       random-weighted cfdg ;

IN: cfdg.models.aqua-star

: tentacle ( -- )
iterate? [
  { { 1 [ circle
          [ .23 y .99 s .002 b tentacle ] do ] }
    { 1 [ circle
          [ .17 y 2 r .99 s .002 b tentacle ] do ] }
    { 1 [ circle
          [ .12 y -2 r .99 s .001 b tentacle ] do ] } }
  call-random-weighted
] when ;

: anemone ( -- )
iterate? [
  tentacle
  [ 10 x -11 r .995 s -.002 b anemone ] do
] when ;

: anemone-begin ( -- ) [ 196 hue 0.8324 sat 1 b anemone ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init ( -- )
  [ -1 b ]             >background
  { -60 140 -120 140 } >viewport
  0.1                  >threshold
  [ anemone-begin ]    >start-shape ;

: run ( -- ) [ init ] cfdg-window. ;

MAIN: run
