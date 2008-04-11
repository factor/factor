
USING: kernel arrays sequences random
       math
       math.ranges
       math.functions
       math.vectors
       multi-methods accessors
       combinators.cleave
       processing
       bubble-chamber.common
       bubble-chamber.particle
       bubble-chamber.particle.muon.colors ;

IN: bubble-chamber.particle.muon

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: muon < particle ;

: <muon> ( -- muon ) muon construct-empty initialize-particle ;

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

