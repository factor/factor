USING: kernel math arrays math.vectors math.matrices namespaces make
math.constants math.functions splitting grouping math.trig sequences
accessors 4DNav.deep models vars ;
IN: 4DNav.turtle

! replacement of self

VAR: self

: with-self ( quot obj -- ) [ >self call ] with-scope ; inline

: save-self ( quot -- ) self> [ self> clone >self call ] dip >self ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: turtle pos ori ;

: <turtle> ( -- turtle )
    turtle new
    { 0 0 0 } clone >>pos
    3 identity-matrix >>ori
;


TUPLE: observer < turtle projection-mode collision-mode ;

: <observer> ( -- object ) 
     observer new
    0 <model> >>projection-mode 
    f <model> >>collision-mode
    ;


: turtle-pos> ( -- val ) self> pos>> ;
: >turtle-pos ( val -- ) self> (>>pos) ;

: turtle-ori> ( -- val ) self> ori>> ;
: >turtle-ori ( val -- ) self> (>>ori) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! These rotation matrices are from
! `Computer Graphics: Principles and Practice'


! waiting for deep-cleave-quots  

! : Rz ( angle -- Rx ) deg>rad
!    {   { [ cos ] [ sin neg ]   0 }
!        { [ sin ] [ cos ]      0  }
!        {   0       0           1 } 
!    } deep-cleave-quots  ;

! : Ry ( angle -- Ry ) deg>rad
!    {   { [ cos ]      0 [ sin ] }
!        {   0          1 0       }
!        { [  sin neg ] 0 [ cos ] }
!    } deep-cleave-quots  ;
  
! : Rx ( angle -- Rz ) deg>rad
!   {   { 1     0        0        }
!        { 0   [ cos ] [ sin neg ] }
!        { 0   [ sin ] [ cos ]     }
!    } deep-cleave-quots ;

: Rz ( angle -- Rx ) deg>rad
[ dup cos ,     dup sin neg ,   0 ,
  dup sin ,     dup cos ,       0 ,
  0 ,           0 ,             1 , ] 3 make-matrix nip ;

: Ry ( angle -- Ry ) deg>rad
[ dup cos ,     0 ,             dup sin ,
  0 ,           1 ,             0 ,
  dup sin neg , 0 ,             dup cos , ] 3 make-matrix nip ;

: Rx ( angle -- Rz ) deg>rad
[ 1 ,           0 ,             0 ,
  0 ,           dup cos ,       dup sin neg ,
  0 ,           dup sin ,       dup cos , ] 3 make-matrix nip ;


! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: apply-rotation ( rotation -- ) 
    turtle-ori> swap m. >turtle-ori ;
: rotate-x ( angle -- ) Rx apply-rotation ;
: rotate-y ( angle -- ) Ry apply-rotation ;
: rotate-z ( angle -- ) Rz apply-rotation ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: pitch-up   ( angle -- ) neg rotate-x ;
: pitch-down ( angle -- )     rotate-x ;

: turn-left ( angle -- )      rotate-y ;
: turn-right ( angle -- ) neg rotate-y ;

: roll-left  ( angle -- ) neg rotate-z ;
: roll-right ( angle -- )     rotate-z ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! roll-until-horizontal
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: V ( -- V ) { 0 1 0 } ;

: X ( -- 3array ) turtle-ori> [ first  ] map ;
: Y ( -- 3array ) turtle-ori> [ second ] map ;
: Z ( -- 3array ) turtle-ori> [ third  ] map ;

: set-X ( seq -- ) turtle-ori> [ set-first ] 2each ;
: set-Y ( seq -- ) turtle-ori> [ set-second ] 2each ;
: set-Z ( seq -- ) turtle-ori> [ set-third ] 2each ;

: roll-until-horizontal ( -- )
    V Z cross normalize set-X
    Z X cross normalize set-Y ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: distance ( turtle turtle -- n ) 
    pos>> swap pos>> v- [ sq ] map sum sqrt ;

: move-by ( point -- ) turtle-pos> v+ >turtle-pos ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: reset-turtle ( -- ) 
    { 0 0 0 } clone >turtle-pos 3 identity-matrix >turtle-ori ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: step-vector ( length -- array ) { 0 0 1 } n*v ;

: step-turtle ( length -- ) 
    step-vector turtle-ori> swap m.v 
    turtle-pos> v+ >turtle-pos ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: strafe-up ( length -- )
    90 pitch-up
    step-turtle
    90 pitch-down ;

: strafe-down ( length -- )
    90 pitch-down
    step-turtle
    90 pitch-up ;

: strafe-left ( length -- )
    90 turn-left
    step-turtle
    90 turn-right ;

: strafe-right ( length -- )
    90 turn-right
    step-turtle
    90 turn-left ;
