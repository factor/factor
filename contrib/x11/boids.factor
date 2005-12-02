! Eduardo Cavazos - wayo.cavazos@gmail.com

IN: boids

USING: namespaces math kernel sequences arrays xlib x ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: separation-radius   100 separation-radius set
SYMBOL: alignment-radius    100 alignment-radius set
SYMBOL: cohesion-radius     100 cohesion-radius set

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: separation-view-angle   90 separation-view-angle set
SYMBOL: alignment-view-angle    90 alignment-view-angle set
SYMBOL: cohesion-view-angle     90 cohesion-view-angle set

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: separation-weight   1.0 separation-weight set
SYMBOL: alignment-weight    0.5 alignment-weight set
SYMBOL: cohesion-weight     1.0 cohesion-weight set

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: world-size   { 400 400 } world-size set

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: boid pos vel ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: time-slice   0.5 time-slice set

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! random-boid and random-boids
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : random-range dupd swap - random-int + ;

: random-range ( a b -- n ) 1 + dupd swap - random-int + ;

! : random-n ( n -- random-0-to-n-1 )
!   1 - 0 swap random-int ;

: random-pos ( -- pos )
  world-size get [ random-int ] map ;

: random-vel ( -- vel )
  2 >array [ drop -10 10 random-range ] map ;

: random-boid ( -- boid ) random-pos random-vel <boid> ;

: random-boids ( n -- boids ) >array [ drop random-boid ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: boids

: setup-window
  ":0.0" initialize-x
  create-window win set
  world-size get resize-window
  map-window
  flush-dpy
  50 random-boids   boids set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! draw-boid
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: boid-point-a ( boid -- point-a ) boid-pos ;

: boid-point-b ( boid -- point-b )
  dup >r boid-pos
  r> boid-vel normalize 20 v*n
  v+ ;

: boid-points ( boid -- point-a point-b )
  dup >r boid-point-a r> boid-point-b ;

: draw-boid ( boid -- ) boid-points draw-line ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: distance ( boid boid -- n )
  boid-pos swap boid-pos v- norm ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: r->d ( radians -- degrees ) 180 * pi / ;
  
: constrain ( n a b -- n )
  >r max r> min ;

: angle-between ( vec vec -- angle )
  2dup >r >r
  v.   r> norm r> norm *   /   -1 1 constrain acos r->d ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: relative-angle ( self other -- angle )
  over >r >r
  boid-vel   r> boid-pos r> boid-pos v-   angle-between ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: vsum ( vector-of-vectors --- vec )
  { 0 0 } [ v+ ] reduce ;

: average-position ( boids -- pos )
  [ boid-pos ] map   dup >r   vsum   r>   length   v/n ;

: average-velocity ( boids -- vel )
  [ boid-vel ] map   dup >r   vsum   r>   length   v/n ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: subset-with ( obj seq quot -- seq | quot: obj elt -- elt )
  [ >r dup r> ] swap append subset ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: within-radius? ( self other radius -- ? )
  >r distance r> <= ;

: within-view-angle? ( self other view-angle -- ? )
  >r relative-angle r> 2 / <= ;

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

: separation-force ( self -- force )
  ! boids get [ within-separation-neighborhood? ] subset-with
  boids get [ >r dup r> within-separation-neighborhood? ] subset
  dup length 0 =
  [ drop drop { 0 0 } ]
  [ average-position
    >r boid-pos r> v-
    normalize
    separation-weight get
    v*n ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: alignment-force ( self -- force )
  ! boids get [ within-alignment-neighborhood? ] subset-with
  boids get [ >r dup r> within-alignment-neighborhood? ] subset swap drop
  dup length 0 =
  [ drop { 0 0 } ]
  [ average-velocity
    normalize
    alignment-weight get
    v*n ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: cohesion-force ( self -- force )
  ! boids get [ within-cohesion-neighborhood? ] subset-with
  boids get [ >r dup r> within-cohesion-neighborhood? ] subset
  dup length 0 =
  [ drop drop { 0 0 } ]
  [ average-position
    swap ! avg-pos self
    boid-pos v-
    normalize
    cohesion-weight get
    v*n ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! F = m a
!
! We let m be equal to 1 so then this is simply: F = a

! : acceleration ( boid -- acceleration )
!  dup >r dup >r
!  separation-force r> alignment-force r> cohesion-force v+ v+ ;

: acceleration ( boid -- acceleration )
  dup dup
  separation-force rot
  alignment-force  rot
  cohesion-force v+ v+ ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! iterate-boid
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: new-pos ( boid -- pos )
  dup >r   boid-pos   r> boid-vel time-slice get v*n   v+ ;

! : new-vel ( boid -- vel )
!   dup >r   boid-vel   r> acceleration time-slice get v*n   v+ ;

: new-vel ( boid -- vel )
  dup boid-vel swap acceleration time-slice get v*n   v+ ;

: wrap-x ( x -- x )
  dup   0 world-size get nth   >=   [ drop 0 ] when
  dup   0 < [ drop 0 world-size get nth   1 - ] when ;

: wrap-y ( y -- y )
  dup   1 world-size get nth   >=   [ drop 0 ] when
  dup   0 < [ drop 1 world-size get nth   1 - ] when ;

: wrap-pos ( pos -- pos )
  [ ] each
  wrap-y swap wrap-x swap 2array ;

: iterate-boid ( self -- self )
  dup >r new-pos wrap-pos r> new-vel <boid> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: iterate-boids ( -- )
  boids get [ iterate-boid ] map   boids set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: draw-boids ( -- )
  boids get [ draw-boid ] each flush-dpy ;

: run-boids ( -- )
  iterate-boids clear-window draw-boids run-boids ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Comments from others:
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! slava foo get blah foo set ==> foo [ blah ] change
! slava dup >r blah r> ==> [ blah ] keep

! : execute-with ( item [ word word ... ] -- results ... )
!   [ over >r execute r> ] each drop ;

