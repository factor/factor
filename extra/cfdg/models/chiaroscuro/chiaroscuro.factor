
USING: kernel namespaces sequences math
       opengl.gl opengl.glu ui ui.gadgets.slate
       random-weighted cfdg ;

IN: cfdg.models.chiaroscuro

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: white

: black ( -- )
  {
    { 60 [ 0.6 s circle ] [ 0.1 x 5 r 0.99 s -0.01 b -0.01 a black ] }
    {  1 [ white black ]                                             }
  }
  rules ;

: white ( -- )
  {
    { 60 [ 0.6 s circle ] [ 0.1 x -5 r 0.99 s 0.01 b -0.01 a white ] }
    {  1 [ black white ] }
  }
  rules ;

: chiaroscuro ( -- ) { [ 0.5 b black ] } rule ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init ( -- )
  [ -0.5 b ]      >background
  { -3 6 -2 6 }   >viewport
  0.03            >threshold  
  [ chiaroscuro ] >start-shape ;

: run ( -- ) [ init ] cfdg-window. ;

MAIN: run
