
USING: kernel namespaces math opengl.gl opengl.glu ui ui.gadgets.slate
       random-weighted cfdg ;

IN: cfdg.models.lesson

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: shapes ( -- )
[            square ]   do
[ 0.3 b      circle ]   do
[ 0.5 b      triangle ] do
[ 0.7 b 60 r triangle ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: chapter-1 ( -- )
[ 2 x 5 y 3 size square ] do
[ 6 x 5 y 3 size circle ] do
[ 4 x 2 y 3 size triangle ] do
[     1 y 3 size shapes ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: foursquare ( -- )
[ 0 x 0 y 5 3 size* square ] do
[ 0 x 5 y 2 4 size* square ] do
[ 5 x 5 y   3 size  square ] do
[ 5 x 0 y   2 size  square ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: chapter-2 ( -- )
[ square ] do
[ 3 x 7 y square ] do
[ 5 x 7 y 30 r square ] do
[ 3 x 5 y 0.75 size square ] do
[ 5 x 5 y 0.5 b square ] do
[ 7 x 6 y 45 r 0.7 size 0.7 b square ] do
[ 5 x 1 y 10 r 0.2 size foursquare ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: spiral ( -- )
iterate? [
  [ 0.5 size circle ] do
  [ 0.2 y -3 r 0.995 size spiral ] do
] when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: chapter-3 ( -- ) [ 0 x 3 y spiral ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: tree

: branch-left ( -- )
{ { 1 [ 20 r tree ] }
  { 1 [ 30 r tree ] }
  { 1 [ 40 r tree ] }
  { 1 [ ] } } random-weighted* do ;

: branch-right ( -- )
{ { 1 [ -20 r tree ] }
  { 1 [ -30 r tree ] }
  { 1 [ -40 r tree ] }
  { 1 [ ] } } random-weighted* do ;

: branch ( -- ) branch-left branch-right ;

: tree ( -- )
iterate? [
  { 
    { 20  [ [ 0.25 size circle ] do
      	    [ 0.1 y 0.97 size tree ] do ] }
    { 1.5 [ branch ] }
  } random-weighted* do
] when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: chapter-4 ( -- )
[ 1 x 0 y tree ] do
[ 6 x 0 y tree ] do
[ 1 x 4 y tree ] do
[ 6 x 4 y tree ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: toc ( -- )
[ 0  x   0 y chapter-1 ] do
[ 10 x   0 y chapter-2 ] do
[ 0  x -10 y chapter-3 ] do
[ 10 x -10 y chapter-4 ] do ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: run ( -- )
[ ] >background
{ -5 25 -15 25 } viewport set
0.03 threshold set
[ toc ] start-shape set
cfdg-window ;

MAIN: run

