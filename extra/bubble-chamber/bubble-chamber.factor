
USING: kernel syntax accessors sequences
       arrays calendar
       combinators.cleave combinators.short-circuit 
       locals math math.constants math.functions math.libm
       math.order math.points math.vectors
       namespaces random sequences threads ui ui.gadgets ui.gestures
       math.ranges
       colors
       colors.gray
       vars
       multi-methods
       multi-method-syntax
       processing.shapes
       frame-buffer ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

IN: bubble-chamber

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! This is a Factor implementation of an art piece by Jared Tarbell:
!
!   http://complexification.net/gallery/machines/bubblechamber/
!
! Jared's version is written in Processing (Java)

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! processing
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: 2random ( a b -- num ) 2dup swap - 100 / <range> random ;

: 1random ( b -- num ) 0 swap 2random ;

: at-fraction ( seq fraction -- val ) over length 1- * swap nth ;

: at-fraction-of ( fraction seq -- val ) swap at-fraction ;

: mouse ( -- point ) hand-loc get ;

: mouse-x ( -- x ) mouse first  ;
: mouse-y ( -- y ) mouse second ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! bubble-chamber.particle
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: collide ( particle -- )
GENERIC: move    ( particle -- )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: particle
  bubble-chamber pos vel speed speed-d theta theta-d theta-dd myc mya ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: initialize-particle ( particle -- particle )

  0 0 {2} >>pos
  0 0 {2} >>vel

  0 >>speed
  0 >>speed-d
  0 >>theta
  0 >>theta-d
  0 >>theta-dd

  0 0 0 1 rgba boa >>myc
  0 0 0 1 rgba boa >>mya ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: center ( particle -- point ) bubble-chamber>> size>> 2 v/n ;

DEFER: collision-theta

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: move-by ( obj delta -- obj ) over pos>> v+ >>pos ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: theta-dd-small? ( par limit -- par ? ) [ dup theta-dd>> abs ] dip < ;

: random-theta-dd  ( par a b -- par ) 2random >>theta-dd ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: turn ( particle -- particle )
  dup
    [ speed>> ] [ theta>> { sin cos } <arr> ] bi n*v
  >>vel ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: step-theta     ( p -- p ) [ ] [ theta>>   ] [ theta-d>>  ] tri + >>theta   ;
: step-theta-d   ( p -- p ) [ ] [ theta-d>> ] [ theta-dd>> ] tri + >>theta-d ;
: step-speed-sub ( p -- p ) [ ] [ speed>>   ] [ speed-d>>  ] tri - >>speed   ;
: step-speed-mul ( p -- p ) [ ] [ speed>>   ] [ speed-d>>  ] tri * >>speed   ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: out-of-bounds? ( PARTICLE -- ? )
  [let | X      [ PARTICLE pos>> first                    ]
         Y      [ PARTICLE pos>> second                   ]
         WIDTH  [ PARTICLE bubble-chamber>> size>> first  ]
         HEIGHT [ PARTICLE bubble-chamber>> size>> second ] |

    [let | LEFT   [ WIDTH  neg ]
           RIGHT  [ WIDTH  2 * ]
           BOTTOM [ HEIGHT neg ]
           TOP    [ HEIGHT 2 * ] |

      { [ X LEFT < ] [ X RIGHT > ] [ Y BOTTOM < ] [ Y TOP > ] } 0|| ] ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! bubble-chamber.particle.axion
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <axion> < particle ;

: axion ( -- <axion> ) <axion> new initialize-particle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: collide ( <axion> -- )

  dup center          >>pos
  2 pi *      1random >>theta
  1.0   6.0   2random >>speed
  0.998 1.000 2random >>speed-d
  0                   >>theta-d
  0                   >>theta-dd

  [ 0.00001 theta-dd-small? ] [ -0.001 0.001 random-theta-dd ] while

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: dy>alpha ( dy -- alpha ) neg 6 * 30 + 255.0 / ;

! : axion-white ( dy -- dy ) dup 1 swap dy>alpha {2} \ stroke-color set ;
! : axion-black ( dy -- dy ) dup 0 swap dy>alpha {2} \ stroke-color set ;

: axion-white ( dy -- dy ) dup 1 swap dy>alpha gray boa \ stroke-color set ;
: axion-black ( dy -- dy ) dup 0 swap dy>alpha gray boa \ stroke-color set ;

: axion-point- ( particle dy -- particle ) [ dup pos>> ] dip v-y point ;
: axion-point+ ( particle dy -- particle ) [ dup pos>> ] dip v+y point ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: move ( <axion> -- )

  T{ gray f 0.06 0.59 } \ stroke-color set
  dup pos>>  point

  1 4 [a,b] [ axion-white axion-point- ] each
  1 4 [a,b] [ axion-black axion-point+ ] each

  dup vel>> move-by

  turn

  step-theta
  step-theta-d
  step-speed-mul

  [ ] [ speed-d>> 0.9999 * ] bi >>speed-d

  1000 random 996 >
    [
      dup speed>>   neg     >>speed
      dup speed-d>> neg 2 + >>speed-d

      100 random 30 > [ collide ] [ drop ] if
    ]
    [ drop ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! bubble-chamber.particle.hadron
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <hadron> < particle ;

: hadron ( -- <hadron> ) <hadron> new initialize-particle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: collide ( <hadron> -- )

  dup center          >>pos
  2 pi *      1random >>theta
  0.5   3.5   2random >>speed
  0.996 1.001 2random >>speed-d
  0                   >>theta-d
  0                   >>theta-dd

  [ 0.00001 theta-dd-small? ] [ -0.001 0.001 random-theta-dd ] while

  0 1 0 1 rgba boa >>myc

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: move ( <hadron> -- )

  T{ gray f 1 0.11 } \ stroke-color set  dup pos>> 1 v-y point
  T{ gray f 0 0.11 } \ stroke-color set  dup pos>> 1 v+y point

  dup vel>> move-by

  turn

  step-theta
  step-theta-d
  step-speed-mul

  1000 random 997 >
    [
      1.0     >>speed-d
      0.00001 >>theta-dd

      100 random 70 > [ dup collide ] when
    ]
  when

  dup out-of-bounds? [ collide ] [ drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! bubble-chamber.particle.muon.colors
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: good-colors ( -- seq )
  {
    T{ rgba f 0.23 0.14 0.17 1 }
    T{ rgba f 0.23 0.14 0.15 1 }
    T{ rgba f 0.21 0.14 0.15 1 }
    T{ rgba f 0.51 0.39 0.33 1 }
    T{ rgba f 0.49 0.33 0.20 1 }
    T{ rgba f 0.55 0.45 0.32 1 }
    T{ rgba f 0.69 0.63 0.51 1 }
    T{ rgba f 0.64 0.39 0.18 1 }
    T{ rgba f 0.73 0.42 0.20 1 }
    T{ rgba f 0.71 0.45 0.29 1 }
    T{ rgba f 0.79 0.45 0.22 1 }
    T{ rgba f 0.82 0.56 0.34 1 }
    T{ rgba f 0.88 0.72 0.49 1 }
    T{ rgba f 0.85 0.69 0.40 1 }
    T{ rgba f 0.96 0.92 0.75 1 }
    T{ rgba f 0.99 0.98 0.87 1 }
    T{ rgba f 0.85 0.82 0.69 1 }
    T{ rgba f 0.99 0.98 0.87 1 }
    T{ rgba f 0.82 0.82 0.79 1 }
    T{ rgba f 0.65 0.69 0.67 1 }
    T{ rgba f 0.53 0.60 0.55 1 }
    T{ rgba f 0.57 0.53 0.68 1 }
    T{ rgba f 0.47 0.42 0.56 1 }
  } ;

: anti-colors ( -- seq ) good-colors <reversed> ; 

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: color-fraction ( particle -- particle fraction ) dup theta>> pi + 2 pi * / ;

: set-good-color ( particle -- particle )
  color-fraction dup 0 1 between?
    [ good-colors at-fraction-of >>myc ]
    [ drop ]
  if ;

: set-anti-color ( particle -- particle )
  color-fraction dup 0 1 between?
    [ anti-colors at-fraction-of >>mya ]
    [ drop ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! bubble-chamber.particle.muon
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <muon> < particle ;

: muon ( -- <muon> ) <muon> new initialize-particle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: collide ( <muon> -- )

  dup center           >>pos
  2 32 [a,b] random    >>speed
  0.0001 0.001 2random >>speed-d

  dup collision-theta  -0.1 0.1 2random + >>theta
  0                                    >>theta-d
  0                                    >>theta-dd

  [ 0.001 theta-dd-small? ] [ -0.1 0.1 random-theta-dd ] while

  set-good-color
  set-anti-color

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: move ( <muon> -- )

  [let | MUON [ ] |

    [let | WIDTH [ MUON bubble-chamber>> size>> first ] |

      MUON

      dup myc>> 0.16 >>alpha \ stroke-color set
      dup pos>> point

      dup mya>> 0.16 >>alpha \ stroke-color set
      dup pos>> first2 [ WIDTH swap - ] dip 2array point

      dup
      [ speed>> ] [ theta>> { sin cos } <arr> ] bi n*v
      move-by

      step-theta
      step-theta-d
      step-speed-sub

      dup out-of-bounds? [ collide ] [ drop ] if ] ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! bubble-chamber.particle.quark
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <quark> < particle ;

: quark ( -- <quark> ) <quark> new initialize-particle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: collide ( <quark> -- )

  dup center                             >>pos
  dup collision-theta -0.11 0.11 2random +  >>theta
  0.5 3.0 2random                        >>speed

  0.996 1.001 2random                    >>speed-d
  0                                      >>theta-d
  0                                      >>theta-dd

  [ 0.00001 theta-dd-small? ] [ -0.001 0.001 random-theta-dd ] while

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: move ( <quark> -- )

  [let | QUARK [ ] |

    [let | WIDTH [ QUARK bubble-chamber>> size>> first ] |

      QUARK
    
      dup myc>> 0.13 >>alpha \ stroke-color set
      dup pos>>              point

      dup pos>> first2 [ WIDTH swap - ] dip 2array point

      [ ] [ vel>> ] bi move-by

      turn

      step-theta
      step-theta-d
      step-speed-mul

      1000 random 997 >
      [
      dup speed>> neg    >>speed
      2 over speed-d>> - >>speed-d
      ]
      when

      dup out-of-bounds? [ collide ] [ drop ] if ] ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE: syntax ! Switch back to non-multi-method 'TUPLE:' syntax

TUPLE: <bubble-chamber> < <frame-buffer>
  paused particles collision-theta size ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : randomize-collision-theta ( bubble-chamber -- bubble-chamber )
!   0  2 pi *  0.001  <range>  random >>collision-theta ;

: randomize-collision-theta ( bubble-chamber -- bubble-chamber )
  pi neg  pi  0.001 <range> random >>collision-theta ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: collision-theta ( particle -- theta ) bubble-chamber>> collision-theta>> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: <bubble-chamber> pref-dim* ( gadget -- dim ) size>> ;

M: <bubble-chamber> ungraft* ( <bubble-chamber> -- ) t >>paused drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: iterate-particle ( particle -- ) move ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M:: <bubble-chamber> update-frame-buffer ( BUBBLE-CHAMBER -- )

  BUBBLE-CHAMBER particles>> [ iterate-particle ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: iterate-system ( <bubble-chamber> -- ) drop ;

:: start-bubble-chamber-thread ( GADGET -- )
  GADGET f >>paused drop
  [
    [
      GADGET paused>>
        [ f ]
        [ GADGET iterate-system GADGET relayout-1 1 milliseconds sleep t ]
      if
    ]
    loop
  ]
  in-thread ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bubble-chamber ( -- <bubble-chamber> )
  <bubble-chamber> new-gadget
    { 1000 1000 } >>size
    randomize-collision-theta ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bubble-chamber-window ( -- <bubble-chamber> )
  bubble-chamber
    dup start-bubble-chamber-thread
    dup "Bubble Chamber" open-window ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: add-particle ( BUBBLE-CHAMBER PARTICLE -- bubble-chamber )
  
  PARTICLE BUBBLE-CHAMBER >>bubble-chamber drop

  BUBBLE-CHAMBER  BUBBLE-CHAMBER particles>> PARTICLE suffix  >>particles ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: mouse->collision-theta ( BUBBLE-CHAMBER -- BUBBLE-CHAMBER )
  mouse
  BUBBLE-CHAMBER size>> 2 v/n
  v-
  first2
  fatan2
  BUBBLE-CHAMBER (>>collision-theta)
  BUBBLE-CHAMBER ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: mouse-pressed ( BUBBLE-CHAMBER -- )

  BUBBLE-CHAMBER mouse->collision-theta drop

  11
  [
    BUBBLE-CHAMBER particles>> [ <hadron>? ] filter random [ collide ] when*
    BUBBLE-CHAMBER particles>> [ <quark>?  ] filter random [ collide ] when*
    BUBBLE-CHAMBER particles>> [ <muon>?   ] filter random [ collide ] when*
  ]
  times ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<bubble-chamber> H{ { T{ button-down } [ mouse-pressed ] } } set-gestures

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: collide-random-particle ( bubble-chamber -- bubble-chamber )
  dup particles>> random collide ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: big-bang ( bubble-chamber -- bubble-chamber )
  dup particles>> [ collide ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: collide-one-of-each ( bubble-chamber -- bubble-chamber )
  dup
  particles>>
  [ [ <muon>?   ] filter random collide ]
  [ [ <quark>?  ] filter random collide ]
  [ [ <hadron>? ] filter random collide ]
  tri ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Some initial configurations
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: ten-hadrons ( -- )
  bubble-chamber-window
  10 [ drop hadron add-particle ] each
  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: original ( -- )
  
  bubble-chamber-window
  
    1789 [ muon   add-particle ] times
    1300 [ quark  add-particle ] times
    1000 [ hadron add-particle ] times
     111 [ axion  add-particle ] times

    particles>>
    [ [ <muon>?   ] filter random collide ]
    [ [ <quark>?  ] filter random collide ]
    [ [ <hadron>? ] filter random collide ]
    tri ;
    
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: hadron-chamber ( -- )
  bubble-chamber-window
  1000 [ hadron add-particle ] times
  big-bang
  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: quark-chamber ( -- )
  bubble-chamber-window
  100 [ quark add-particle ] times
  big-bang
  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: small ( -- )
  <bubble-chamber> new-gadget
    { 200 200 } >>size
    randomize-collision-theta
    dup start-bubble-chamber-thread
    dup "Bubble Chamber" open-window

    42 [ muon   add-particle ] times
    30 [ quark  add-particle ] times
    21 [ hadron add-particle ] times
     7 [ axion  add-particle ] times

    collide-one-of-each

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: medium ( -- )
  <bubble-chamber> new-gadget
    { 400 400 } >>size
    randomize-collision-theta
    dup start-bubble-chamber-thread
    dup "Bubble Chamber" open-window

    100 [ muon   add-particle ] times
     81 [ quark  add-particle ] times
     60 [ hadron add-particle ] times
      9 [ axion  add-particle ] times

    collide-one-of-each

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: large ( -- )
  <bubble-chamber> new-gadget
    { 600 600 } >>size
    randomize-collision-theta
    dup start-bubble-chamber-thread
    dup "Bubble Chamber" open-window

    550 [ muon   add-particle ] times
    339 [ quark  add-particle ] times
    100 [ hadron add-particle ] times
     11 [ axion  add-particle ] times

    collide-one-of-each

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Experimental
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: muon-chamber ( -- )
  bubble-chamber-window
  1000 [ muon add-particle ] times
  dup particles>> [ collide randomize-collision-theta ] each
  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: original-big-bang ( -- )
  bubble-chamber
    { 1000 1000 } >>size
    dup start-bubble-chamber-thread
    dup "Bubble Chamber" open-window

  1789 [ muon   add-particle ] times
  1300 [ quark  add-particle ] times
  1000 [ hadron add-particle ] times
   111 [ axion  add-particle ] times

  big-bang

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: original-big-bang-variant ( -- )
  bubble-chamber-window
  1789 [ muon   add-particle ] times
  1300 [ quark  add-particle ] times
  1000 [ hadron add-particle ] times
   111 [ axion  add-particle ] times
  dup particles>> [ collide randomize-collision-theta ] each
  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

