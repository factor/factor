REQUIRES: contrib/math
          contrib/vars
          contrib/lindenmayer/opengl
          contrib/slate ;

USING: kernel namespaces math sequences arrays threads opengl gadgets
       math-contrib vars opengl-contrib slate ;

IN: boids

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: boid pos vel ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: boids
VAR: world-size
VAR: time-slice

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: cohesion-weight
VAR: alignment-weight
VAR: separation-weight

VAR: cohesion-view-angle
VAR: alignment-view-angle
VAR: separation-view-angle

VAR: cohesion-radius
VAR: alignment-radius
VAR: separation-radius

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-variables ( -- )
1.0 >cohesion-weight
1.0 >alignment-weight
1.0 >separation-weight

75 >cohesion-radius
50 >alignment-radius
25 >separation-radius

180 >cohesion-view-angle
180 >alignment-view-angle
180 >separation-view-angle

10 >time-slice ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! random-boid and random-boids
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: random-range ( a b -- n ) 1 + dupd swap - random-int + ;

: random-pos ( -- pos ) world-size> [ random-int ] map ;

: random-vel ( -- vel ) 2 >array [ drop -10 10 random-range ] map ;

: random-boid ( -- boid ) random-pos random-vel <boid> ;

: random-boids ( n -- boids ) [ drop random-boid ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! draw-boid
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: boid-point-a ( boid -- a ) boid-pos ;

: boid-point-b ( boid -- b ) dup boid-pos swap boid-vel normalize 20 v*n v+ ;

: boid-points ( boid -- point-a point-b ) dup boid-point-a swap boid-point-b ;

: draw-line ( a b -- )
GL_LINES glBegin first2 glVertex2i first2 glVertex2i glEnd ;

: draw-boid ( boid -- ) boid-points draw-line ;

: draw-boids ( -- ) boids> [ draw-boid ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: distance ( boid boid -- n ) boid-pos swap boid-pos v- norm ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: constrain ( n a b -- n ) rot min max ;

: angle-between ( vec vec -- angle )
2dup v. -rot norm swap norm * / -1 1 constrain acos rad>deg ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: relative-position ( self other -- v ) boid-pos swap boid-pos v- ;

: relative-angle ( self other -- angle )
over boid-vel -rot relative-position angle-between ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: vsum ( vector-of-vectors --- vec ) { 0 0 } [ v+ ] reduce ;

: vaverage ( seq-of-vectors -- seq ) dup vsum swap length v/n ;

: average-position ( boids -- pos ) [ boid-pos ] map vaverage ;

: average-velocity ( boids -- vel ) [ boid-vel ] map vaverage ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: within-radius? ( self other radius -- ? ) >r distance r> <= ;

: within-view-angle? ( self other angle -- ? ) >r relative-angle r> 2 / <= ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: within-cohesion-radius? ( self other -- ? )
  cohesion-radius get within-radius? ;

: within-cohesion-view? ( self other -- ? )
  cohesion-view-angle get within-view-angle? ;

: within-cohesion-neighborhood? ( self other -- ? )
  [ eq? not ] 2keep
  [ within-cohesion-radius? ] 2keep
  within-cohesion-view?
  and and ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: within-separation-radius? ( self other -- ? )
  separation-radius get within-radius? ;

: within-separation-view? ( self other -- ? )
  separation-view-angle get within-view-angle? ;

: within-separation-neighborhood? ( self other -- ? )
  [ eq? not ] 2keep
  [ within-separation-radius? ] 2keep
  within-separation-view?
  and and ;  

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: within-alignment-radius? ( self other -- ? )
  alignment-radius get within-radius? ;

: within-alignment-view? ( self other -- ? )
  alignment-view-angle get within-view-angle? ;

: within-alignment-neighborhood? ( self other -- ? )
  [ eq? not ] 2keep
  [ within-alignment-radius? ] 2keep
  within-alignment-view?
  and and ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: cohesion-neighborhood ( self -- boids )
boids> [ within-cohesion-neighborhood? ] subset-with ;

: cohesion-force ( self -- force )
dup cohesion-neighborhood
dup length 0 =
[ 2drop { 0 0 } ]
[ average-position swap boid-pos v- normalize cohesion-weight> v*n ]
if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: separation-neighborhood ( self -- boids )
boids> [ within-separation-neighborhood? ] subset-with ;

: separation-force ( self -- force )
dup separation-neighborhood
dup length 0 =
[ 2drop { 0 0 } ]
[ average-position swap boid-pos swap v- normalize separation-weight> v*n ]
if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: alignment-neighborhood ( self -- boids )
boids> [ within-alignment-neighborhood? ] subset-with ;

: alignment-force ( self -- force )
alignment-neighborhood
dup length 0 =
[ drop { 0 0 } ]
[ average-velocity normalize alignment-weight get v*n ]
if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! F = m a
!
! We let m be equal to 1 so then this is simply: F = a

: acceleration ( boid -- acceleration )
  dup dup
  separation-force rot
  alignment-force  rot
  cohesion-force v+ v+ ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! iterate-boid
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: world-width ( -- w ) world-size> first ;

: world-height ( -- w ) world-size> second ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: below? ( n a b -- ? ) drop < ;

: above? ( n a b -- ? ) nip > ;

: wrap ( n a b -- n )
{ { [ 3dup below? ]
    [ 2nip ] }
  { [ 3dup above? ]
    [ drop nip ] }
  { [ t ]
    [ 2drop ] } }
cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: wrap-x ( x -- x ) 0 world-width 1- wrap ;

: wrap-y ( y -- y ) 0 world-height 1- wrap ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: new-pos ( boid -- pos ) dup boid-vel time-slice> v*n swap boid-pos v+ ;

: new-vel ( boid -- vel )
dup acceleration time-slice> v*n swap boid-vel v+ normalize ;

: wrap-pos ( pos -- pos ) first2 wrap-y swap wrap-x swap 2array ;

: iterate-boid ( self -- self ) dup >r new-pos wrap-pos r> new-vel <boid> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: iterate-boids ( -- ) boids> [ iterate-boid ] map >boids ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: display ( -- ) GL_COLOR_BUFFER_BIT glClear black gl-color draw-boids ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: stop?

: run ( -- )
slate> rect-dim >world-size
iterate-boids .slate 1 sleep
stop? get [ ] [ run ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-slate ( -- )
<slate> >slate
namespace slate> set-slate-ns
[ display ] >action
slate> "Boids" open-titled-window ;

: init-boids ( -- ) 50 random-boids >boids ;

: init-world-size ( -- ) { 100 100 } >world-size ;

: init ( -- ) init-slate init-variables init-world-size init-boids stop? off ;