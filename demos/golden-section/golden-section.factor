USING: kernel namespaces math arrays sequences opengl gadgets
       opengl.colors slate ;

IN: golden-section

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! To run:
! 
! USE: golden-section
! golden-section-window

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gl-translate-2f ( point -- ) first2 0 glTranslatef ;

: disk ( quadric radius center -- )
glPushMatrix
gl-translate-2f
dup 0 glScalef
0 1 10 10 gluDisk
glPopMatrix ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: phi ( -- phi ) 5 sqrt 1 + 2 / 1 - ;

: omega ( i -- omega ) phi * 2 * pi * ;

: x ( i -- x ) dup omega cos * 0.5 * ;

: y ( i -- y ) dup omega sin * 0.5 * ;

: center ( i -- point ) dup x swap y 2array ;

: radius ( i -- radius ) pi * 720 / sin 10 * ;

: color ( i -- color ) 360.0 / dup 0.25 1 4array ;

: rim ( quadric i -- )
black gl-color dup radius 1.5 * swap center disk ;

: inner ( quadric i -- )
dup color gl-color dup radius swap center disk ;

: dot ( quadric i -- ) 2dup rim inner ;

: golden-section ( quadric -- ) 720 [ dot ] each-with ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: with-quadric ( quot -- )
gluNewQuadric [ swap call ] keep gluDeleteQuadric ; inline

: display ( -- )
GL_PROJECTION glMatrixMode
glLoadIdentity
-400 400 -400 400 -1 1 glOrtho
GL_MODELVIEW glMatrixMode
glLoadIdentity
[ golden-section ] with-quadric ;

: golden-section-window ( -- )
[ display ] <slate>
{ 600 600 } over set-slate-dim
"Golden Section" open-window ;