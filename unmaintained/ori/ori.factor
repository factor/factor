
USING: kernel namespaces make accessors
       math math.constants math.functions math.matrices math.vectors
       sequences splitting grouping self math.trig ;

IN: ori

TUPLE: ori val ;

C: <ori> ori

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: ori> ( -- val ) self> val>> ;

: >ori ( val -- ) self> val<< ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make-matrix ( quot width -- matrix ) [ { } make ] dip group ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! These rotation matrices are from
! `Computer Graphics: Principles and Practice'

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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: apply-rotation ( rotation -- ) ori> swap m. >ori ;

: rotate-x ( angle -- ) Rx apply-rotation ;
: rotate-y ( angle -- ) Ry apply-rotation ;
: rotate-z ( angle -- ) Rz apply-rotation ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: pitch-up   ( angle -- ) neg rotate-x ;
: pitch-down ( angle -- )     rotate-x ;

: turn-left ( angle -- )      rotate-y ;
: turn-right ( angle -- ) neg rotate-y ;

: roll-left  ( angle -- ) neg rotate-z ;
: roll-right ( angle -- )     rotate-z ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! roll-until-horizontal
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: V ( -- V ) { 0 1 0 } ;

: X ( -- 3array ) ori> [ first  ] map ;
: Y ( -- 3array ) ori> [ second ] map ;
: Z ( -- 3array ) ori> [ third  ] map ;

: set-X ( seq -- ) ori> [ set-first ] 2each ;
: set-Y ( seq -- ) ori> [ set-second ] 2each ;
: set-Z ( seq -- ) ori> [ set-third ] 2each ;

: roll-until-horizontal ( -- )
V Z cross normalize set-X
Z X cross normalize set-Y ;

