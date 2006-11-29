REQUIRES: libs/alien ;
USING: kernel sequences opengl alien-contrib ;
IN: opengl-contrib

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gl-clear-color ( 4seq -- ) first4 glClearColor ;

: gl-vertex-3f ( 3seq -- ) first3 glVertex3f ;

: gl-vertex ( 3seq -- ) gl-vertex-3f ;

: gl-normal-3f ( vec -- ) first3 glNormal3f ;

: gl-normal ( vec -- ) gl-normal-3f ;

: gl-material-fv ( face pname params -- ) >float-array glMaterialfv ;

: gl-color ( vec -- ) first4 glColor4f ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Misc stuff that should probably go in a separate file
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: black ( -- color ) { 0 0 0 1 } ;

: white ( -- color ) { 1 1 1 1 } ;

: red ( -- color ) { 1 0 0 1 } ;

: green ( -- color ) { 0 1 0 1 } ;

: blue ( -- color ) { 0 0 1 1 } ;

: yellow ( -- color ) { 1 1 0 1 } ;

: set-color-alpha ( color alpha -- color ) swap 3 head swap add ;

