
USING: kernel arrays sequences random math accessors multi-methods
       processing
       bubble-chamber.common
       bubble-chamber.particle ;

IN: bubble-chamber.particle.quark

TUPLE: quark < particle ;

: <quark> ( -- quark ) quark new initialize-particle ;

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
