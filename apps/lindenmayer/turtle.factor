REQUIRES: libs/math libs/vars ;
USING: kernel math namespaces sequences arrays math-contrib vars ;
IN: turtle

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: turtle position orientation ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: turtle

: position> ( -- position ) turtle> turtle-position ;

: >position ( position -- ) turtle> set-turtle-position ;

: orientation> ( -- orientation ) turtle> turtle-orientation ;

: >orientation ( orientation -- ) turtle> set-turtle-orientation ;

: with-turtle ( quot turtle -- ) [ >turtle call ] with-scope ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: reset-turtle ( -- ) { 0 0 0 } >position 3 identity-matrix >orientation ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C: turtle ( -- ) [ reset-turtle ] over with-turtle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make-matrix >r { } make r> group ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! These rotation matrices are from
! `Computer Graphics: Principles and Practice'

: Rz ( angle -- Rx ) deg>rad
[ dup cos ,	dup sin neg ,	0 ,
  dup sin ,	dup cos ,	0 ,
  0 ,		0 ,		1 , ] 3 make-matrix nip ;

: Ry ( angle -- Ry ) deg>rad
[ dup cos ,	0 ,		dup sin ,
  0 ,		1 ,		0 ,
  dup sin neg ,	0 ,		dup cos , ] 3 make-matrix nip ;

: Rx ( angle -- Rz ) deg>rad
[ 1 ,		0 ,		0 ,
  0 ,		dup cos ,	dup sin neg ,
  0 ,		dup sin ,	dup cos , ] 3 make-matrix nip ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: apply-rotation ( rotation -- ) orientation> swap m. >orientation ;

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

: step-vector ( length -- array ) { 0 0 1 } n*v ;

: step-turtle ( length -- )
step-vector orientation> swap m.v position> v+ >position ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: turtle-stack

: init-turtle-stack ( -- ) V{ } clone >turtle-stack ;

: push-turtle ( -- ) turtle> clone turtle-stack> push ;

! : pop-turtle ( -- ) turtle-stack> pop >turtle ;

: pop-turtle ( -- )
turtle-stack> pop dup
turtle-position >position
turtle-orientation >orientation ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! roll-until-horizontal
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: V ( -- V ) { 0 1 0 } ;

: X ( -- 3array ) orientation> [ first  ] map ;
: Y ( -- 3array ) orientation> [ second ] map ;
: Z ( -- 3array ) orientation> [ third  ] map ;

: set-X ( seq -- ) orientation> [ 0 swap set-nth ] 2each ;
: set-Y ( seq -- ) orientation> [ 1 swap set-nth ] 2each ;
: set-Z ( seq -- ) orientation> [ 2 swap set-nth ] 2each ;

: roll-until-horizontal ( -- )
V Z cross normalize set-X
Z X cross normalize set-Y ;

