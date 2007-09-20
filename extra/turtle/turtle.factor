
USING: kernel math arrays math.vectors math.matrices generic.lib pos ori ;

IN: turtle

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: turtle ;

: <turtle> ( -- turtle )
turtle construct-empty
{ 0 0 0 } clone <pos>
3 identity-matrix <ori>
rot
3array chain ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: reset-turtle ( -- ) { 0 0 0 } >pos 3 identity-matrix >ori ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: step-vector ( length -- array ) { 0 0 1 } n*v ;

: step-turtle ( length -- ) step-vector ori> swap m.v pos> v+ >pos ;

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
