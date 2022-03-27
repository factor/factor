USING: accessors arrays ascii calendar colors colors.gray
combinators.short-circuit kernel math math.constants
math.functions math.libm math.order math.points math.vectors
namespaces opengl processing.shapes quotations random ranges
sequences splitting timers ui ui.gadgets ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.frame-buffer ui.gadgets.packs
ui.gestures ;

IN: bubble-chamber

! This is a Factor implementation of an art piece by Jared Tarbell:
!
!   http://complexification.net/gallery/machines/bubblechamber/
!
! Jared's version is written in Processing (Java)

: 2random ( a b -- num ) 2dup swap - 100 / <range> random ;

: 1random ( b -- num ) 0 swap 2random ;

: at-fraction ( seq fraction -- val ) over length 1 - * >integer swap nth ;

: at-fraction-of ( fraction seq -- val ) swap at-fraction ;

: mouse ( -- point ) hand-loc get ;

: mouse-x ( -- x ) mouse first  ;
: mouse-y ( -- y ) mouse second ;

: draw ( point -- )
    gl-scale-factor get-global [
        stroke-color get fill-color set
        >integer draw-circle
    ] [
        draw-point
    ] if* ;

GENERIC: collide ( particle -- )
GENERIC: move    ( particle -- )

TUPLE: particle
    bubble-chamber pos vel speed speed-d theta theta-d theta-dd myc mya ;

: initialize-particle ( particle -- particle )

  { 0 0 } >>pos
  { 0 0 } >>vel

  0 >>speed
  0 >>speed-d
  0 >>theta
  0 >>theta-d
  0 >>theta-dd

  0 0 0 1 rgba boa >>myc
  0 0 0 1 rgba boa >>mya ;

: center ( particle -- point ) bubble-chamber>> size>> 2 v/n ;

DEFER: collision-theta

: move-by ( obj delta -- obj ) over pos>> v+ >>pos ;

: theta-dd-small? ( par limit -- par ? ) [ dup theta-dd>> abs ] dip < ;

: random-theta-dd  ( par a b -- par ) 2random >>theta-dd ;

: turn ( particle -- particle )
  dup
    [ speed>> ] [ theta>> [ sin ] [ cos ] bi 2array ] bi n*v
  >>vel ;

: step-theta     ( p -- p ) [ ] [ theta>>   ] [ theta-d>>  ] tri + >>theta   ;
: step-theta-d   ( p -- p ) [ ] [ theta-d>> ] [ theta-dd>> ] tri + >>theta-d ;
: step-speed-sub ( p -- p ) [ ] [ speed>>   ] [ speed-d>>  ] tri - >>speed   ;
: step-speed-mul ( p -- p ) [ ] [ speed>>   ] [ speed-d>>  ] tri * >>speed   ;

:: out-of-bounds? ( PARTICLE -- ? )
    PARTICLE pos>> first :> X
    PARTICLE pos>> second :> Y
    PARTICLE bubble-chamber>> size>> first :> WIDTH
    PARTICLE bubble-chamber>> size>> second :> HEIGHT

    WIDTH  neg :> LEFT
    WIDTH  2 * :> RIGHT
    HEIGHT neg :> BOTTOM
    HEIGHT 2 * :> TOP

    { [ X LEFT < ] [ X RIGHT > ] [ Y BOTTOM < ] [ Y TOP > ] } 0|| ;

TUPLE: axion < particle ;

: <axion> ( -- axion ) axion new initialize-particle ;

M: axion collide

  dup center          >>pos
  2 pi *      1random >>theta
  1.0   6.0   2random >>speed
  0.998 1.000 2random >>speed-d
  0                   >>theta-d
  0                   >>theta-dd

  [ 0.00001 theta-dd-small? ] [ -0.001 0.001 random-theta-dd ] while

  drop ;

: dy>alpha ( dy -- alpha ) neg 6 * 30 + 255.0 / ;

! : axion-white ( dy -- dy ) dup 1 swap dy>alpha 2array stroke-color set ;
! : axion-black ( dy -- dy ) dup 0 swap dy>alpha 2array stroke-color set ;

: axion-white ( dy -- dy ) dup 1 swap dy>alpha gray boa stroke-color set ;
: axion-black ( dy -- dy ) dup 0 swap dy>alpha gray boa stroke-color set ;

: axion-point- ( particle dy -- particle ) [ dup pos>> ] dip v-y draw ;
: axion-point+ ( particle dy -- particle ) [ dup pos>> ] dip v+y draw ;

M: axion move

  T{ gray f 0.06 0.59 } stroke-color set
  dup pos>> draw

  4 [1..b] [ axion-white axion-point- ] each
  4 [1..b] [ axion-black axion-point+ ] each

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

TUPLE: hadron < particle ;

: <hadron> ( -- hadron ) hadron new initialize-particle ;

M: hadron collide

  dup center          >>pos
  2 pi *      1random >>theta
  0.5   3.5   2random >>speed
  0.996 1.001 2random >>speed-d
  0                   >>theta-d
  0                   >>theta-dd

  [ 0.00001 theta-dd-small? ] [ -0.001 0.001 random-theta-dd ] while

  0 1 0 1 rgba boa >>myc

  drop ;

M: hadron move

  T{ gray f 1 0.11 } stroke-color set  dup pos>> 1 v-y draw
  T{ gray f 0 0.11 } stroke-color set  dup pos>> 1 v+y draw

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

CONSTANT: good-colors {
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
}

: anti-colors ( -- seq ) good-colors <reversed> ;

: color-fraction ( particle -- particle fraction ) dup theta>> pi + 2 pi * / ;

: set-good-color ( particle -- particle )
    color-fraction dup 0 1 between?
    [ good-colors at-fraction-of >>myc ] [ drop ] if ;

: set-anti-color ( particle -- particle )
    color-fraction dup 0 1 between?
    [ anti-colors at-fraction-of >>mya ] [ drop ] if ;

TUPLE: muon < particle ;

: <muon> ( -- muon ) muon new initialize-particle ;

M: muon collide

  dup center           >>pos
  2 32 [a..b] random    >>speed
  0.0001 0.001 2random >>speed-d

  dup collision-theta  -0.1 0.1 2random + >>theta
  0                                    >>theta-d
  0                                    >>theta-dd

  [ 0.001 theta-dd-small? ] [ -0.1 0.1 random-theta-dd ] while

  set-good-color
  set-anti-color

  drop ;

M:: muon move ( MUON -- )

    MUON bubble-chamber>> size>> first :> WIDTH

    MUON

    dup myc>> >rgba-components drop 0.16 <rgba> stroke-color set
    dup pos>> draw

    dup mya>> >rgba-components drop 0.16 <rgba> stroke-color set
    dup pos>> first2 [ WIDTH swap - ] dip 2array draw

    dup
    [ speed>> ] [ theta>> [ sin ] [ cos ] bi 2array ] bi n*v
    move-by

    step-theta
    step-theta-d
    step-speed-sub

    dup out-of-bounds? [ collide ] [ drop ] if ;

TUPLE: quark < particle ;

: <quark> ( -- quark ) quark new initialize-particle ;

M: quark collide

  dup center                             >>pos
  dup collision-theta -0.11 0.11 2random +  >>theta
  0.5 3.0 2random                        >>speed

  0.996 1.001 2random                    >>speed-d
  0                                      >>theta-d
  0                                      >>theta-dd

  [ 0.00001 theta-dd-small? ] [ -0.001 0.001 random-theta-dd ] while

  drop ;

M:: quark move ( QUARK -- )

    QUARK bubble-chamber>> size>> first :> WIDTH

    QUARK

    dup myc>> >rgba-components drop 0.13 <rgba> stroke-color set
    dup pos>> draw

    dup pos>> first2 [ WIDTH swap - ] dip 2array draw

    [ ] [ vel>> ] bi move-by

    turn

    step-theta
    step-theta-d
    step-speed-mul

    1000 random 997 > [
        dup speed>> neg    >>speed
        2 over speed-d>> - >>speed-d
    ] when

    dup out-of-bounds? [ collide ] [ drop ] if ;

TUPLE: bubble-chamber < frame-buffer
  particles collision-theta size timer ;

M: bubble-chamber graft*
    [ timer>> start-timer ] [ call-next-method ] bi ;

M: bubble-chamber ungraft*
    [ timer>> stop-timer ] [ call-next-method ] bi ;

! : randomize-collision-theta ( bubble-chamber -- bubble-chamber )
!     0  2 pi *  0.001  <range>  random >>collision-theta ;

: randomize-collision-theta ( bubble-chamber -- bubble-chamber )
    pi neg  pi  0.001 <range> random >>collision-theta ;

: collision-theta ( particle -- theta ) bubble-chamber>> collision-theta>> ;

M: bubble-chamber pref-dim* ( gadget -- dim ) size>> ;

: iterate-particle ( particle -- ) move ;

M:: bubble-chamber update-frame-buffer ( BUBBLE-CHAMBER -- )
    BUBBLE-CHAMBER particles>> [ iterate-particle ] each ;

: iterate-system ( bubble-chamber -- ) drop ;

: <bubble-chamber> ( -- bubble-chamber )
    bubble-chamber new
        { 1000 1000 } >>size
        randomize-collision-theta
        dup '[ _ dup iterate-system relayout-1 ]
        f 10 milliseconds <timer> >>timer ;

: bubble-chamber-window ( -- bubble-chamber )
    <bubble-chamber> dup "Bubble Chamber" open-window ;

:: add-particle ( BUBBLE-CHAMBER PARTICLE -- bubble-chamber )
    PARTICLE BUBBLE-CHAMBER >>bubble-chamber drop
    BUBBLE-CHAMBER [ PARTICLE suffix ] change-particles ;

:: mouse->collision-theta ( BUBBLE-CHAMBER -- BUBBLE-CHAMBER )
    mouse
    BUBBLE-CHAMBER size>> 2 v/n
    v-
    first2
    fatan2
    BUBBLE-CHAMBER collision-theta<<
    BUBBLE-CHAMBER ;

:: mouse-pressed ( BUBBLE-CHAMBER -- )
    BUBBLE-CHAMBER mouse->collision-theta drop

    11 [
        BUBBLE-CHAMBER particles>> [ hadron? ] filter random [ collide ] when*
        BUBBLE-CHAMBER particles>> [ quark?  ] filter random [ collide ] when*
        BUBBLE-CHAMBER particles>> [ muon?   ] filter random [ collide ] when*
    ] times ;

bubble-chamber H{
    { T{ button-down } [ mouse-pressed ] }
} set-gestures

: collide-random-particle ( bubble-chamber -- bubble-chamber )
    dup particles>> random collide ;

: big-bang ( bubble-chamber -- bubble-chamber )
    dup particles>> [ collide ] each ;

: collide-one-of-each ( bubble-chamber -- bubble-chamber )
    dup
    particles>>
    [ [ muon?   ] filter random collide ]
    [ [ quark?  ] filter random collide ]
    [ [ hadron? ] filter random collide ]
    tri ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: ten-hadrons ( -- )
    bubble-chamber-window
    10 [ <hadron> add-particle ] times
    drop ;

: original ( -- )
    bubble-chamber-window

    1789 [ <muon>   add-particle ] times
    1300 [ <quark>  add-particle ] times
    1000 [ <hadron> add-particle ] times
     111 [ <axion>  add-particle ] times

    particles>>
    [ [ muon?   ] filter random collide ]
    [ [ quark?  ] filter random collide ]
    [ [ hadron? ] filter random collide ]
    tri ;

: hadron-chamber ( -- )
    bubble-chamber-window
    1000 [ <hadron> add-particle ] times
    big-bang
    drop ;

: quark-chamber ( -- )
    bubble-chamber-window
    100 [ <quark> add-particle ] times
    big-bang
    drop ;

: small ( -- )
    <bubble-chamber>
    { 200 200 } >>size
    dup "Bubble Chamber" open-window

    42 [ <muon>   add-particle ] times
    30 [ <quark>  add-particle ] times
    21 [ <hadron> add-particle ] times
     7 [ <axion>  add-particle ] times

    collide-one-of-each
    drop ;

: medium ( -- )
    <bubble-chamber>
    { 400 400 } >>size
    dup "Bubble Chamber" open-window

    100 [ <muon>   add-particle ] times
     81 [ <quark>  add-particle ] times
     60 [ <hadron> add-particle ] times
      9 [ <axion>  add-particle ] times

    collide-one-of-each
    drop ;

: large ( -- )
    <bubble-chamber>
    { 600 600 } >>size
    dup "Bubble Chamber" open-window

    550 [ <muon>   add-particle ] times
    339 [ <quark>  add-particle ] times
    100 [ <hadron> add-particle ] times
     11 [ <axion>  add-particle ] times

    collide-one-of-each
    drop ;

: muon-chamber ( -- )
    bubble-chamber-window
    1000 [ <muon> add-particle ] times
    dup particles>> [ collide randomize-collision-theta ] each
    drop ;

: original-big-bang ( -- )
    <bubble-chamber>
    { 1000 1000 } >>size
    dup "Bubble Chamber" open-window

    1789 [ <muon>   add-particle ] times
    1300 [ <quark>  add-particle ] times
    1000 [ <hadron> add-particle ] times
     111 [ <axion>  add-particle ] times

    big-bang
    drop ;

: original-big-bang-variant ( -- )
    bubble-chamber-window
    1789 [ <muon>   add-particle ] times
    1300 [ <quark>  add-particle ] times
    1000 [ <hadron> add-particle ] times
     111 [ <axion>  add-particle ] times
    dup particles>> [ collide randomize-collision-theta ] each
    drop ;

MAIN-WINDOW: run-bubble-chamber { { title "Bubble Chamber" } }
    <filled-pile> { 2 2 } >>gap {
        original small medium large hadron-chamber
        quark-chamber muon-chamber ten-hadrons
        original-big-bang original-big-bang-variant
    } [
        [ name>> "-" " " replace >title ]
        [ 1quotation [ drop ] prepend ] bi
        <border-button> add-gadget
    ] each { 2 2 } <border> >>gadgets ;
