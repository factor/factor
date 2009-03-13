
USING: kernel combinators sequences arrays math math.vectors
       generalizations vars accessors math.physics.vel ;

IN: springies

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: scalar-projection ( a b -- n ) [ v. ] [ nip norm ] 2bi / ;

: vector-projection ( a b -- vec )
  [ nip normalize ] [ scalar-projection ] 2bi v*n ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: nodes
VAR: springs
VAR: time-slice
VAR: world-size

: world-width ( -- width ) world-size> first ;

: world-height ( -- height ) world-size> second ;

VAR: gravity

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! node
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: node < vel mass elas force ;

C: <node> node

: node-vel ( node -- vel ) vel>> ;

: set-node-vel ( vel node -- ) swap >>vel drop ;

: pos-x ( node -- x ) pos>> first ;
: pos-y ( node -- y ) pos>> second ;
: vel-x ( node -- y ) vel>> first ;
: vel-y ( node -- y ) vel>> second ;

: >>pos-x ( node x -- node ) over pos>> set-first ;
: >>pos-y ( node y -- node ) over pos>> set-second ;
: >>vel-x ( node x -- node ) over vel>> set-first ;
: >>vel-y ( node y -- node ) over vel>> set-second ;

: apply-force ( node vec -- ) over force>> v+ >>force drop ;

: reset-force ( node -- node ) 0 0 2array >>force ;

: node-id ( id -- node ) 1- nodes> nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! spring
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: spring rest-length k damp node-a node-b ;

C: <spring> spring

: end-points ( spring -- b-pos a-pos )
  [ node-b>> pos>> ] [ node-a>> pos>> ] bi ;

: spring-length ( spring -- length ) end-points v- norm ;

: stretch-length ( spring -- length )
  [ spring-length ] [ rest-length>> ] bi - ;

: dir ( spring -- vec ) end-points v- normalize ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Hooke
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 
! F = -kx
! 
! k :: spring constant
! x :: distance stretched beyond rest length
! 
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: hooke-force-mag ( spring -- mag ) [ k>> ] [ stretch-length ] bi * ;

: hooke-force ( spring -- force ) [ dir ] [ hooke-force-mag ] bi v*n ;

: hooke-forces ( spring -- a b ) hooke-force dup vneg ;

: act-on-nodes-hooke ( spring -- )
  [ node-a>> ] [ node-b>> ] [ ] tri hooke-forces swapd
  apply-force
  apply-force ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! damping
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 
! F = -bv
! 
! b :: Damping constant
! v :: Velocity
! 
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : damping-force-a ( spring -- vec )
!   [ spring-node-a node-vel ] [ spring-damp ] bi v*n vneg ;

! : damping-force-b ( spring -- vec )
!   [ spring-node-b node-vel ] [ spring-damp ] bi v*n vneg ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: relative-velocity-a ( spring -- vel )
  [ node-a>> vel>> ] [ node-b>> vel>> ] bi v- ;

: unit-vec-b->a ( spring -- vec )
  [ node-a>> pos>> ] [ node-b>> pos>> ] bi v- ;

: relative-velocity-along-spring-a ( spring -- vel )
  [ relative-velocity-a ] [ unit-vec-b->a ] bi vector-projection ;

: damping-force-a ( spring -- vec )
  [ relative-velocity-along-spring-a ] [ damp>> ] bi v*n vneg ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: relative-velocity-b ( spring -- vel )
  [ node-b>> vel>> ] [ node-a>> vel>> ] bi v- ;

: unit-vec-a->b ( spring -- vec )
  [ node-b>> pos>> ] [ node-a>> pos>> ] bi v- ;

: relative-velocity-along-spring-b ( spring -- vel )
  [ relative-velocity-b ] [ unit-vec-a->b ] bi vector-projection ;

: damping-force-b ( spring -- vec )
  [ relative-velocity-along-spring-b ] [ damp>> ] bi v*n vneg ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: act-on-nodes-damping ( spring -- )
  dup
  [ node-a>> ] [ damping-force-a ] bi apply-force
  [ node-b>> ] [ damping-force-b ] bi apply-force ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: below? ( node -- ? ) pos-y 0 < ;

: above? ( node -- ? ) pos-y world-height >= ;

: beyond-left? ( node -- ? ) pos-x 0 < ; 

: beyond-right? ( node -- ? ) pos-x world-width >= ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bounce-top ( node -- )
  world-height 1- >>pos-y
  dup [ vel-y ] [ elas>> ] bi * neg >>vel-y
  drop ;

: bounce-bottom ( node -- )
  0 >>pos-y
  dup [ vel-y ] [ elas>> ] bi * neg >>vel-y
  drop ;

: bounce-left ( node -- )
  0 >>pos-x
  dup [ vel-x ] [ elas>> ] bi * neg >>vel-x
  drop ;

: bounce-right ( node -- )
  world-width 1- >>pos-x
  dup [ vel-x ] [ elas>> ] bi * neg >>vel-x
  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: handle-bounce ( node -- )
  { { [ dup above? ]        [ bounce-top ] }
    { [ dup below? ]        [ bounce-bottom ] }
    { [ dup beyond-left? ]  [ bounce-left ] }
    { [ dup beyond-right? ] [ bounce-right ] }
    { [ t ]                 [ drop ] } }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: act-on-nodes ( spring -- )
  dup
  act-on-nodes-hooke
  act-on-nodes-damping ;

! : act-on-nodes ( spring -- ) act-on-nodes-hooke ;

: loop-over-springs ( -- ) springs> [ act-on-nodes ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: apply-gravity ( node -- ) { 0 -9.8 } apply-force ;

: do-gravity ( -- ) gravity> [ nodes> [ apply-gravity ] each ] when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! F = ma

: calc-acceleration ( node -- vec ) [ force>> ] [ mass>> ] bi v/n ;

: new-vel ( node -- vel )
  [ vel>> ] [ calc-acceleration time-slice> v*n ] bi v+ ;

: new-pos ( node -- pos ) [ pos>> ] [ vel>> time-slice> v*n ] bi v+ ;

: iterate-node ( node -- )
  dup new-pos >>pos
  dup new-vel >>vel
  reset-force
  handle-bounce ;

: iterate-nodes ( -- ) nodes> [ iterate-node ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: iterate-system ( -- ) do-gravity loop-over-springs iterate-nodes ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Reading xspringies data files
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: mass ( id x y x-vel y-vel mass elas -- )
  node new
    swap >>elas
    swap >>mass
    -rot 2array >>vel
    -rot 2array >>pos
    0 0  2array >>force
  nodes> swap suffix >nodes
  drop ;

: spng ( id id-a id-b k damp rest-length -- )
   spring new
     swap >>rest-length
     swap >>damp
     swap >>k
     swap node-id >>node-b
     swap node-id >>node-a
   springs> swap suffix >springs
   drop ;