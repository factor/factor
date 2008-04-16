
USING: kernel sequences random accessors multi-methods
       math math.constants math.ranges math.points combinators.cleave
       processing bubble-chamber.common bubble-chamber.particle ;

IN: bubble-chamber.particle.axion

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: axion < particle ;

: <axion> ( -- axion ) axion new initialize-particle ;

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
