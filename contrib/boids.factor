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
180 >separation-view-angle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! random-boid and random-boids
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: random-range ( a b -- n ) 1 + dupd swap - random-int + ;

: random-pos ( -- pos ) world-size get [ random-int ] map ;

: random-vel ( -- vel ) 2 >array [ drop -10 10 random-range ] map ;

: random-boid ( -- boid ) random-pos random-vel <boid> ;

: random-boids ( n -- boids ) [ drop random-boid ] map ;

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

: new-pos ( boid -- pos ) dup boid-vel time-slice> v*n swap boid-pos v+ ;

: new-vel ( boid -- vel )
dup acceleration time-slice> v*n swap boid-vel v+ normalize ;

: wrap-pos ( pos -- pos ) first2 wrap-y swap wrap-x swap 2array ;

: iterate-boid ( self -- self ) dup >r new-pos wrap-pos r> new-vel <boid> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: iterate-boids ( -- ) boids> [ iterate-boid ] map >boids ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : draw-boids ( -- ) boids get [ draw-boid ] each flush-dpy ;

: draw-boids ( -- )
reset-slate   white set-clear-color   black set-color   clear-window
boids get [ draw-boid ] each   flush-dlist flush-slate ;

! : run-boids ( -- ) iterate-boids clear-window draw-boids 1 sleep run-boids ;

VAR: stop?

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
       gadgets-text gadgets-buttons ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: [bind] ( ns quot -- quot ) \ bind 3array >quotation ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VARS: ns frame ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: number-field-quot ( symbol -- quot )
1array >quotation [ set ] append [ editor-text string>number ] swap append ;

: number-field ( label symbol init -- gadget )
swap number-field-quot ns> swap [bind] f swap <field> tuck set-editor-text
swap <label> swap
2array make-shelf ;

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
"Alignment:  " alignment-weight "1" number-field
"Cohesion:   " cohesion-weight  "1" number-field
"Separation: " alignment-weight "1" number-field
3array append

"Radius" <label> dup title-theme 1array
"Alignment:  " alignment-radius  "50" number-field
"Cohesion:   " cohesion-radius   "75" number-field
"Separation: " separation-radius "25" number-field
3array append

"View angle" <label> dup title-theme 1array
"Alignment:  " alignment-view-angle  "180" number-field
"Cohesion:   " cohesion-view-angle   "180" number-field
"Separation: " separation-view-angle "180" number-field
3array append

"" <label> dup title-theme 1array

"Time slice: " time-slice "10" number-field 1array

"Stop" ns> [ drop t stop? set ] [bind] <bevel-button>
"Start" ns> [ drop f stop? set [ run-boids ] in-thread ] [bind] <bevel-button>
"Reset" ns> [ drop 50 random-boids boids set ] [bind] <bevel-button>
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

