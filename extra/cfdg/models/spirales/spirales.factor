
USING: namespaces sequences math random-weighted cfdg ;

IN: cfdg.models.spirales

DEFER: line

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: block ( -- ) { [ circle ] [ 0.3 s 60 flip line ] } rule ;

: a1 ( -- ) { [ 0.95 s 2 x 12 r 0.5 b 10 hue 1.5 sat a1 ] [ block ] } rule ;

: line ( -- ) -0.3 a { [ 0 r a1 ] [ 120 r a1 ] [ 240 r a1 ] } rule ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init ( -- )
  [ -1 b ]          >background
  { -20 40 -20 40 } >viewport
  [ line ]          >start-shape
  0.04              >threshold ;

: run ( -- ) [ init ] cfdg-window. ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: run