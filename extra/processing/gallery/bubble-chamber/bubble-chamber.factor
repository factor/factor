
USING: kernel namespaces sequences combinators arrays threads

       math
       math.libm
       math.vectors
       math.ranges
       math.constants
       math.functions

       ui
       ui.gadgets

       random accessors multi-methods
       combinators.cleave       
       vars locals

       newfx

       processing
       processing.gadget
       processing.color ;

IN: bubble-chamber

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: 2random ( a b -- num ) 2dup swap - 100 / <range> random ;

: 1random ( b -- num ) 0 swap 2random ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: move-by ( obj delta -- obj ) over pos>> v+ >>pos ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: dim ( -- dim ) 1000 ;

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

: good-color ( i -- color ) good-colors nth-of ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: x>> ( particle -- x ) pos>> first  ;
: y>> ( particle -- x ) pos>> second ;

: >>x ( particle x -- particle ) over y>>      2array >>pos ;
: >>y ( particle y -- particle ) over x>> swap 2array >>pos ;

: x x>> ;
: y y>> ;

: v+y ( seq y -- seq ) >r first2 r> + 2array ;
: v-y ( seq y -- seq ) >r first2 r> - 2array ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: out-of-bounds? ( particle -- particle ? )
  dup
  { [ x dim neg < ] [ x dim 2 * > ] [ y dim neg < ] [ y dim 2 * > ] } cleave
  or or or ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: collide ( particle -- )
GENERIC: move    ( particle -- )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: muon pos speed theta speed-d theta-d theta-dd myc mya ;

: <muon> ( -- muon )
  muon construct-empty
    0 0 2array     >>pos
    0              >>speed
    0              >>speed-d
    0              >>theta
    0              >>theta-d
    0              >>theta-dd
    0 0 0 1 <rgba> >>myc
    0 0 0 1 <rgba> >>mya ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: collide { muon }

  dim 2 / dup 2array     >>pos
  2 32 [a,b] random      >>speed
  0.0001 0.001 2random   >>speed-d

  collision-theta>  -0.1 0.1 2random + >>theta
  0                                    >>theta-d
  0                                    >>theta-dd

  [ dup theta-dd>> abs 0.001 < ]
    [ -0.1 0.1 2random >>theta-dd ]
    [ ]
  while

  dup theta>> pi         +
  2 pi *                 /
  good-colors length 1 - *
  [ ] [ good-colors length >= ] [ 0 < ] tri or
    [ drop ]
    [
      [ good-color >>myc ]
      [ good-colors length swap - 1 - good-color >>mya ]
      bi
    ]
  if

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

  [ ] [ theta>>   ] [ theta-d>>  ] tri + >>theta
  [ ] [ theta-d>> ] [ theta-dd>> ] tri + >>theta-d
  [ ] [ speed>>   ] [ speed-d>>  ] tri - >>speed

  out-of-bounds?
    [ collide ]
    [ drop    ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: quark pos vel speed theta speed-d theta-d theta-dd myc ;

: <quark> ( -- quark )
  quark construct-empty
    0 0 2array     >>pos
    0 0 2array     >>vel
    0              >>speed
    0              >>speed-d
    0              >>theta
    0              >>theta-d
    0              >>theta-dd
    0 0 0 1 <rgba> >>myc ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: collide { quark }

  dim 2 / dup 2array                     >>pos
  collision-theta> -0.11 0.11 2random +  >>theta
  0.5 3.0 2random                        >>speed

  0.996 1.001 2random                    >>speed-d
  0                                      >>theta-d
  0                                      >>theta-dd

  [ dup theta-dd>> abs 0.00001 < ]
    [ -0.001 0.001 2random >>theta-dd ]
    [ ]
  while

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: move { quark }

  dup myc>> 0.13 >>alpha stroke
  dup pos>>              point

  dup pos>> first2 >r dim swap - r> 2array point

  [ ] [ vel>> ] bi move-by

  dup
    [ speed>> ] [ theta>> { sin cos } <arr> ] bi n*v
  >>vel

  [ ] [ theta>>   ] [ theta-d>>  ] tri + >>theta
  [ ] [ theta-d>> ] [ theta-dd>> ] tri + >>theta-d
  [ ] [ speed>>   ] [ speed-d>>  ] tri * >>speed

  1000 random 997 >
    [
      dup speed>> neg    >>speed
      2 over speed-d>> - >>speed-d
    ]
  when

  out-of-bounds?
    [ collide ]
    [ drop    ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: hadron pos vel speed theta speed-d theta-d theta-dd myc ;

: <hadron> ( -- hadron )
  hadron construct-empty
    0 0 2array     >>pos
    0 0 2array     >>vel
    0              >>speed
    0              >>speed-d
    0              >>theta
    0              >>theta-d
    0              >>theta-dd
    0 0 0 1 <rgba> >>myc ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: collide { hadron }

  dim 2 / dup 2array >>pos
  2 pi *  1random    >>theta
  0.5 3.5 2random    >>speed

  0.996 1.001 2random >>speed-d
  0                   >>theta-d
  0                   >>theta-dd

  [ dup theta-dd>> abs 0.00001 < ]
    [ -0.001 0.001 2random >>theta-dd ]
    [ ]
  while

  0 1 0 <rgb> >>myc

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: move { hadron }

  { 1 0.11 } stroke
  dup pos>> 1 v-y point
  
  { 0 0.11 } stroke
  dup pos>> 1 v+y point

  dup vel>> move-by

  dup
    [ speed>> ] [ theta>> { sin cos } <arr> ] bi n*v
  >>vel

  [ ] [ theta>>   ] [ theta-d>>  ] tri + >>theta
  [ ] [ theta-d>> ] [ theta-dd>> ] tri + >>theta-d
  [ ] [ speed>>   ] [ speed-d>>  ] tri * >>speed

  1000 random 997 >
    [
      1.0     >>speed-d
      0.00001 >>theta-dd

      100 random 70 >
        [
          dim 2 / dup 2array >>pos
          dup collide
        ]
      when
    ]
  when

  out-of-bounds?
    [ collide ]
    [ drop ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: axion pos vel speed theta speed-d theta-d theta-dd ;

: <axion> ( -- axion )
  axion construct-empty
    0 0 2array     >>pos
    0 0 2array     >>vel
    0              >>speed
    0              >>speed-d
    0              >>theta
    0              >>theta-d
    0              >>theta-dd ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: collide { axion }

  dim 2 / dup 2array >>pos
  2 pi * 1random     >>theta
  1.0 6.0 2random    >>speed

  0.998 1.000 2random >>speed-d
  0                   >>theta-d
  0                   >>theta-dd

  [ dup theta-dd>> abs 0.00001 < ]
    [ -0.001 0.001 2random >>theta-dd ]
    [ ]
  while

  drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

METHOD: move { axion }

  { 0.06 0.59 } stroke
  dup pos>>  point

  1 4 [a,b]
    [| dy |
      1 30 dy 6 * - 255.0 / 2array stroke
      dup pos>> 0 dy neg 2array v+ point
    ] with-locals
  each

  1 4 [a,b]
    [| dy |
      0 30 dy 6 * - 255.0 / 2array stroke
      dup pos>> dy v+y point
    ] with-locals
  each

  dup vel>> move-by

  dup
    [ speed>> ] [ theta>> { sin cos } <arr> ] bi n*v
  >>vel

  [ ] [ theta>>   ] [ theta-d>>  ] tri + >>theta
  [ ] [ theta-d>> ] [ theta-dd>> ] tri + >>theta-d
  [ ] [ speed>>   ] [ speed-d>>  ] tri * >>speed

  [ ] [ speed-d>> 0.9999 * ] bi >>speed-d

  1000 random 996 >
    [
      dup speed>> neg       >>speed
      dup speed-d>> neg 2 + >>speed-d

      100 random 30 >
        [
          dim 2 / dup 2array >>pos
          collide
        ]
        [ drop ]
      if
    ]
    [ drop ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : draw ( -- )

!   boom>
!     [ particles> [ move ] each ]
!   when ;

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