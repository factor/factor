
USING: kernel random math math.constants math.points accessors multi-methods
       processing
       processing.color
       bubble-chamber.common
       bubble-chamber.particle ;

IN: bubble-chamber.particle.hadron

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
