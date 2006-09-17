REQUIRES: contrib/slate ;
USING: kernel namespaces math sequences opengl slate ;
IN: redbook-cube

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! cube.c from the red book calls glutWireCube to create the
! model. Factor doesn't come with bindings to the GLUT library so we
! whip up wire-cube word here.

:  p dup , ;
: -p dup neg , ;

: wire-cube ( side-length -- )
2.0 /
[ -p -p -p
   p -p -p
   p  p -p
  -p  p -p ] { } make 3 group draw-line-loop
[ -p -p  p
   p -p  p
   p  p  p
  -p  p  p ] { } make 3 group draw-line-loop
[ -p  p -p   -p  p  p
   p  p -p    p  p  p
  -p -p -p   -p -p  p
   p -p -p    p -p  p ] { } make 3 group draw-lines
drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: go ( -- )

slate-window

{ 0 0 0 0 } gl-clear-color
GL_FLAT gl-shade-model

GL_PROJECTION gl-matrix-mode
gl-load-identity
-1 1 -1 1 1.5 20 gl-frustum
GL_MODELVIEW gl-matrix-mode

GL_COLOR_BUFFER_BIT gl-clear
{ 1 1 1 1 } gl-color
gl-load-identity
{ 0 0 5 } { 0 0 0 } { 0 1 0 } glu-look-at
{ 1 2 1 } gl-scale
1 wire-cube

flush-dlist
flush-slate ;