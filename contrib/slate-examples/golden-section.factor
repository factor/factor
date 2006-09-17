
USING: kernel math arrays sequences namespaces opengl slate slate-2d ;

IN: golden-section

! Usage:
! USE: golden-section
! go

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: circle ( center radius -- )
gl-push-matrix
swap 0 add gl-translate   dup 0 3array gl-scale   draw-circle
gl-pop-matrix ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: phi ( -- phi ) 5 sqrt 1 + 2 / 1 - ;

: omega ( i -- omega ) phi * 2 * pi * ;

: x ( i -- x ) dup omega cos * 0.5 * ;

: y ( i -- y ) dup omega sin * 0.5 * ;

: center ( i -- point ) dup x swap y 2array ;

: radius ( i -- radius ) pi * 720 / sin 10 * ;

: color ( i -- color ) 360.0 / dup 0.25 1 4array ;

: rim ( i -- ) black gl-color dup center swap radius 1.5 * circle ;

: inner ( i -- ) dup color gl-color dup center swap radius circle ;

: dot ( i -- ) dup rim inner ;

: golden-section ( -- ) 720 [ dot ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: setup-window ( -- )
slate-window 1000000 capacity set reset-slate -400 400 -400 400 init-2d
GL_COLOR_BUFFER_BIT gl-clear ;

: go ( -- ) setup-window golden-section flush-dlist flush-slate ;