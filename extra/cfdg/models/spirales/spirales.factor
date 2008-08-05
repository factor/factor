
USING: namespaces sequences math random-weighted cfdg ;

IN: cfdg.models.spirales

DEFER: line

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: block ( -- )
  [
    [ circle ] do
    [ 0.3 s 60 flip line ] do
  ]
  recursive ;

: a1 ( -- )
  [
    [ 0.95 s 2 x 12 r 0.5 b 10 hue 1.5 sat a1 ] do
    [ block ] do
  ]
  recursive ;

: line ( -- )
  -0.3 a
  [   0 rotate a1 ] do
  [ 120 rotate a1 ] do
  [ 240 rotate a1 ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init ( -- )
  [ -1 b ] >background
  { -20 40 -20 40 } viewport set
  [ line ] >start-shape
  0.03 >threshold ;

: run ( -- ) [ init ] cfdg-window. ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: run