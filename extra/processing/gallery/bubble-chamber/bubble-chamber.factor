
USING: kernel namespaces sequences combinators arrays threads

       math
       math.libm
       math.vectors
       math.ranges
       math.constants
       math.functions
       math.points

       ui
       ui.gadgets

       random accessors multi-methods
       combinators.cleave       
       vars locals

       newfx

       processing
       processing.gadget
       processing.color ;

IN: processing.gallery.bubble-chamber

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: move-by ( obj delta -- obj ) over pos>> v+ >>pos ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: dim ( -- dim ) 1000 ;

: center ( -- point ) dim 2 / dup {2} ; foldable

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: collision-theta

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: boom

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VARS: particles muons quarks hadrons axions ;

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

: x ( particle -- x ) pos>> first  ;
: y ( particle -- x ) pos>> second ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: out-of-bounds? ( particle -- particle ? )
  dup
  { [ x dim neg < ] [ x dim 2 * > ] [ y dim neg < ] [ y dim 2 * > ] } cleave
  or or or ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: theta-dd-small? ( par limit -- par ? ) >r dup theta-dd>> abs r> < ;

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

TUPLE: particle pos vel speed speed-d theta theta-d theta-dd myc mya ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: initialize-particle ( particle -- particle )

  0 0 {2} >>pos
  0 0 {2} >>vel

  0 >>speed
  0 >>speed-d
  0 >>theta
  0 >>theta-d
  0 >>theta-dd

  0 0 0 1 <rgba> >>myc
  0 0 0 1 <rgba> >>mya ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: collide ( particle -- )
GENERIC: move    ( particle -- )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: muon < particle ;

: <muon> ( -- muon ) muon construct-empty initialize-particle ;

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

METHOD: collide { muon }

  center               >>pos
  2 32 [a,b] random    >>speed
  0.0001 0.001 2random >>speed-d

  collision-theta>  -0.1 0.1 2random + >>theta
  0                                    >>theta-d
  0                                    >>theta-dd

  [ 0.001 theta-dd-small? ] [ -0.1 0.1 random-theta-dd ] [ ] while

  set-good-color
  set-anti-color

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: move { muon }

  dup myc>> 0.16 >>alpha stroke
  dup pos>> point

  dup mya>> 0.16 >>alpha stroke
  dup pos>> first2 >r dim swap - r> 2array point

  dup
    [ speed>> ] [ theta>> { sin cos } <arr> ] bi n*v
  move-by

  step-theta
  step-theta-d
  step-speed-sub

  out-of-bounds? [ collide ] [ drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: quark < particle ;

: <quark> ( -- quark ) quark construct-empty initialize-particle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: collide { quark }

  center                     >>pos
  collision-theta> -0.11 0.11 2random +  >>theta
  0.5 3.0 2random                        >>speed

  0.996 1.001 2random                    >>speed-d
  0                                      >>theta-d
  0                                      >>theta-dd

  [ 0.00001 theta-dd-small? ] [ -0.001 0.001 random-theta-dd ] [ ] while

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: move { quark }

  dup myc>> 0.13 >>alpha stroke
  dup pos>>              point

  dup pos>> first2 >r dim swap - r> 2array point

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

  out-of-bounds? [ collide ] [ drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: hadron < particle ;

: <hadron> ( -- hadron ) hadron construct-empty initialize-particle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: collide { hadron }

  center              >>pos
  2 pi *      1random >>theta
  0.5   3.5   2random >>speed
  0.996 1.001 2random >>speed-d
  0                   >>theta-d
  0                   >>theta-dd

  [ 0.00001 theta-dd-small? ] [ -0.001 0.001 random-theta-dd ] [ ] while

  0 1 0 <rgb> >>myc

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: move { hadron }

  { 1 0.11 } stroke
  dup pos>> 1 v-y point
  
  { 0 0.11 } stroke
  dup pos>> 1 v+y point

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

  out-of-bounds? [ collide ] [ drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: axion < particle ;

: <axion> ( -- axion ) axion construct-empty initialize-particle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: collide { axion }

  center              >>pos
  2 pi *      1random >>theta
  1.0   6.0   2random >>speed
  0.998 1.000 2random >>speed-d
  0                   >>theta-d
  0                   >>theta-dd

  [ 0.00001 theta-dd-small? ] [ -0.001 0.001 random-theta-dd ] [ ] while

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: dy>alpha ( dy -- alpha ) neg 6 * 30 + 255.0 / ;

: axion-white ( dy -- dy ) dup 1 swap dy>alpha {2} stroke ;
: axion-black ( dy -- dy ) dup 0 swap dy>alpha {2} stroke ;

: axion-point- ( particle dy -- particle ) >r dup pos>> r> v-y point ;
: axion-point+ ( particle dy -- particle ) >r dup pos>> r> v+y point ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: move { axion }

  { 0.06 0.59 } stroke
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

: collide-all ( -- )

  2 pi * 1random >collision-theta

  particles> [ collide ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: collide-one ( -- )

  dim 2 / mouse-x - dim 2 / mouse-y - fatan2 >collision-theta

  hadrons> random collide
  quarks>  random collide
  muons>   random collide ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: mouse-pressed ( -- )
  boom on
  1 background ! kludge
  11 [ drop collide-one ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: key-released ( -- )
  key " " =
    [
      boom on
      1 background
      collide-all
    ]
  when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bubble-chamber ( -- )

  1000 1000 size*

  [
    1 background
    no-stroke
  
    1789 [ drop <muon>   ] map >muons
    1300 [ drop <quark>  ] map >quarks
    1000 [ drop <hadron> ] map >hadrons
    111  [ drop <axion>  ] map >axions

    muons> quarks> hadrons> axions> 3append append >particles

    collide-one
  ] setup

  [
    boom>
      [ particles> [ move ] each ]
    when
  ] draw

  [ mouse-pressed ] button-down
  [ key-released  ] key-up

  ;

: go ( -- ) [ bubble-chamber run ] with-ui ;

MAIN: go