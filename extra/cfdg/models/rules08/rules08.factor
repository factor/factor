
USING: namespaces sequences math random-weighted cfdg ;

IN: cfdg.models.rules08

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: insct ( -- )
  [ 1.5 5.5 size* -1 brightness triangle ] do
  10
    [ [ [ 1 0.9 size* -0.15 y 0.05 brightness ] times 1 5 size* triangle ] do ]
  each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: line

: ligne ( -- )
  {
    { 1   [ 4.5 y 1.15 0.8 size* -0.3 b line ] }
    { 0.5 [ ] }
  }
  rules ;

: line ( -- ) { [ insct ligne ] } rule ;

: sole ( -- )
  {
    { 1    [ 1 brightness 0.5 saturation ligne ] [ 140 r 1 hue sole ] }
    { 0.01 [ ] }
  }
  rules ;

: centre ( -- ) { [ 1 b 5 s circle ] [ sole ] } rule ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init ( -- )
  [ -1 b ] >background
  { -20 40 -20 40 } viewport set
  [ centre ] >start-shape
  0.0001 >threshold ;

: run ( -- ) [ init ] cfdg-window. ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: run