
USING: kernel sequences combinators
       math math.vectors math.functions multi-methods
       accessors combinators.cleave processing processing.color
       bubble-chamber.common ;

IN: bubble-chamber.particle

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: collide ( particle -- )
GENERIC: move    ( particle -- )

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

: move-by ( obj delta -- obj ) over pos>> v+ >>pos ;

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

: x ( particle -- x ) pos>> first  ;
: y ( particle -- x ) pos>> second ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: out-of-bounds? ( particle -- particle ? )
  dup
  { [ x dim neg < ] [ x dim 2 * > ] [ y dim neg < ] [ y dim 2 * > ] } cleave
  or or or ;
