REQUIRES: contrib/slate ;
USING: opengl slate ;
IN: redbook-hello

: go ( -- )
slate-window
black gl-clear-color
GL_PROJECTION gl-matrix-mode   gl-load-identity   0 1 0 1 -1 1 gl-ortho
GL_MODELVIEW gl-matrix-mode   gl-load-identity
GL_COLOR_BUFFER_BIT gl-clear
white gl-color
{ { 0.25 0.25 0.0 }
  { 0.75 0.25 0.0 }
  { 0.75 0.75 0.0 }
  { 0.25 0.75 0.0 } }
draw-polygon
flush-dlist
flush-slate ;