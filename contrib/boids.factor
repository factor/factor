! Eduardo Cavazos - wayo.cavazos@gmail.com

! To run the demo do:
! USE: boids
! boids-window
!
! There are currently a few bugs. To work around them and to get better
! results, increase the size of the window (larger than 400x400 is
! good). Then press the "Reset" button to start the demo over.

REQUIRES: math slate vars ;

USING: generic threads namespaces math kernel sequences arrays gadgets
       math-contrib slate vars ;

IN: boids

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: separation-radius
SYMBOL: alignment-radius
SYMBOL: cohesion-radius

SYMBOL: separation-view-angle
SYMBOL: alignment-view-angle
SYMBOL: cohesion-view-angle

SYMBOL: separation-weight
SYMBOL: alignment-weight
SYMBOL: cohesion-weight

: init-variables ( -- )
25 separation-radius set
50 alignment-radius set
75 cohesion-radius set

180 separation-view-angle set
180 alignment-view-angle set
180 cohesion-view-angle set

1.0 separation-weight set
1.0 alignment-weight set
1.0 cohesion-weight set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: world-size

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: boid pos vel ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: time-slice

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! random-boid and random-boids
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: random-range ( a b -- n ) 1 + dupd swap - random-int + ;

: random-pos ( -- pos ) world-size get [ random-int ] map ;

: random-vel ( -- vel ) 2 >array [ drop -10 10 random-range ] map ;

: random-boid ( -- boid ) random-pos random-vel <boid> ;

: random-boids ( n -- boids ) [ drop random-boid ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: boids

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! draw-boid
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: boid-point-a ( boid -- a ) boid-pos ;

: boid-point-b ( boid -- b ) dup boid-pos swap boid-vel normalize 20 v*n v+ ;

: boid-points ( boid -- point-a point-b ) dup boid-point-a swap boid-point-b ;

: draw-boid ( boid -- ) boid-points draw-line ;

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

: subset-with ( obj seq quot -- seq ) [ dupd ] swap append subset ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: within-radius? ( self other radius -- ? ) >r distance r> <= ;

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

: acceleration ( boid -- acceleration )
  dup dup
  separation-force rot
  alignment-force  rot
  cohesion-force v+ v+ ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! iterate-boid
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: world-width ( -- w ) world-size get first ;

: world-height ( -- w ) world-size get second ;

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

! : new-pos ( boid -- pos )
!   dup >r   boid-pos   r> boid-vel time-slice get v*n   v+ ;

! : new-vel ( boid -- vel )
!   dup >r   boid-vel   r> acceleration time-slice get v*n   v+ ;

! : new-vel ( boid -- vel )
!   dup boid-vel swap acceleration time-slice get v*n   v+ ;

! : wrap-x ( x -- x )
!   dup   0 world-size get nth   >=   [ drop 0 ] when
!   dup   0 < [ drop 0 world-size get nth   1 - ] when ;

! : wrap-y ( y -- y )
!   dup   1 world-size get nth   >=   [ drop 0 ] when
!   dup   0 < [ drop 1 world-size get nth   1 - ] when ;

: new-pos ( boid -- pos ) dup boid-vel time-slice> v*n swap boid-pos v+ ;

! : new-vel ( boid -- vel ) dup acceleration time-slice> v*n swap boid-vel v+ ;

: new-vel ( boid -- vel )
dup acceleration time-slice> v*n swap boid-vel v+ normalize ;

: wrap-pos ( pos -- pos ) first2 wrap-y swap wrap-x swap 2array ;

: iterate-boid ( self -- self ) dup >r new-pos wrap-pos r> new-vel <boid> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: iterate-boids ( -- ) boids get [ iterate-boid ] map boids set ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : draw-boids ( -- ) boids get [ draw-boid ] each flush-dpy ;

: draw-boids ( -- )
reset-slate   white set-clear-color   black set-color   clear-window
boids get [ draw-boid ] each   flush-dlist flush-slate ;

! : run-boids ( -- ) iterate-boids clear-window draw-boids 1 sleep run-boids ;

SYMBOL: stop?

: run-boids ( -- )
self get rect-dim world-size set
iterate-boids draw-boids 1 sleep
stop? get [ ] [ run-boids ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: boids-go ( -- )
init-variables
0.1 time-slice set
! 1.0 >min-speed
! 1.0 >max-speed
<slate> dup self set open-window
100 capacity set
self get rect-dim world-size set
50 random-boids boids set
1000 sleep
f stop? set
run-boids ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Boids ui
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: gadgets-frames gadgets-labels gadgets-theme gadgets-grids
       gadgets-editors gadgets-buttons ;

! USING: kernel arrays gadgets  gadgets-labels gadgets-editors vars ;

TUPLE: field label editor quot ;

VAR: field

C: field ( label-text editor-text quot -- <field> )
[ field ]
[ field> set-field-quot
  <editor> field> set-field-editor
  <label> field> set-field-label
  field> field-label field> field-editor 2array make-shelf
  field> set-gadget-delegate
  field> ]
let ;

M: field gadget-gestures
drop H{ { T{ key-down f f "RETURN" } [ dup field-quot call ] } } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: [bind] ( ns quot -- quot ) \ bind 3array >quotation ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VARS: ns frame ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: number-symbol-field ( label init symbol -- <field> )
1array >quotation [ set ] append
[ field-editor editor-text string>number ]
swap append
ns> swap [bind]
<field> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-slate ( -- ) <slate> t over set-gadget-clipped? self set ;

: boids-window ( -- )
<frame> >frame
[ ] make-hash >ns

ns> [ init-slate
      init-variables
      10 time-slice set
      100 capacity set
      { 100 100 } world-size set
      50 random-boids boids set
      f stop? set
] bind

"Weight" <label> dup title-theme 1array
"Alignment:  " "1" alignment-weight  number-symbol-field
"Cohesion:   " "1" cohesion-weight   number-symbol-field
"Separation: " "1" separation-weight number-symbol-field
3array append

"Radius" <label> dup title-theme 1array
"Alignment:  " "50" alignment-radius  number-symbol-field
"Cohesion:   " "75" cohesion-radius   number-symbol-field
"Separation: " "25" separation-radius number-symbol-field
3array append

"View angle" <label> dup title-theme 1array
"Alignment:  " "180" alignment-view-angle  number-symbol-field
"Cohesion:   " "180" cohesion-view-angle   number-symbol-field
"Separation: " "180" separation-view-angle number-symbol-field
3array append

"" <label> dup title-theme 1array

"Time slice: " "10" time-slice number-symbol-field 1array

"Stop" ns> [ t stop? set ] [bind] <bevel-button>
"Start" ns> [ f stop? set [ run-boids ] in-thread ] [bind] <bevel-button>
"Reset" ns> [ 50 random-boids boids set ] [bind] <bevel-button>
3array

append append append append append
make-pile 1 over set-pack-fill frame> @left grid-add

ns> [ self get ] bind frame> @center grid-add
frame> "Boids" open-titled-window
ns> [ 1000 sleep [ run-boids ] in-thread ] bind
;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Comments from others:
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! slava foo get blah foo set ==> foo [ blah ] change
! slava dup >r blah r> ==> [ blah ] keep

! : execute-with ( item [ word word ... ] -- results ... )
!   [ over >r execute r> ] each drop ;

PROVIDE: boids ;

